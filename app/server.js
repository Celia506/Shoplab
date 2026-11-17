// =============================================================================
// ShopLab - API e-commerce de l'application fil rouge
// Implemente les regles metier RG01 a RG07 decrites dans le README.
// =============================================================================
const express = require('express');
const path = require('path');
const { Pool } = require('pg');

const config = {
  port: Number(process.env.APP_PORT || 3000),
  env: process.env.APP_ENV || 'local',
  version: process.env.APP_VERSION || '1.0.0',
};

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: Number(process.env.DB_PORT || 5432),
  user: process.env.DB_USER || 'shoplab',
  password: process.env.DB_PASSWORD || 'shoplab',
  database: process.env.DB_NAME || 'shoplab',
});

const app = express();
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// --- Regles metier -----------------------------------------------------------
const SEUIL_LIVRAISON_OFFERTE = 50.0;
const FRAIS = { STANDARD: 4.9, EXPRESS: 9.9, RETRAIT: 0 };
const TRANSITIONS = {
  CREEE: ['PAYEE', 'ANNULEE'],
  PAYEE: ['EXPEDIEE', 'ANNULEE'],
  EXPEDIEE: ['LIVREE'],
  LIVREE: [],
  ANNULEE: [],
};
const arrondi = (n) => Math.round(n * 100) / 100;

function calculerFrais(mode, montantProduits) {
  if (mode === 'STANDARD' && montantProduits >= SEUIL_LIVRAISON_OFFERTE) return 0; // RG01
  return FRAIS[mode]; // RG01, RG02, RG03
}

function calculerRemise(promo, montantProduits) {
  if (!promo) return 0;
  if (promo.type_remise === 'POURCENTAGE') return arrondi((montantProduits * Number(promo.valeur)) / 100);
  return Math.min(Number(promo.valeur), montantProduits);
}

class ErreurMetier extends Error {
  constructor(message, code = 422) {
    super(message);
    this.code = code;
  }
}

// --- Routes techniques ------------------------------------------------------
app.get('/api/sante', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ statut: 'ok', base: 'ok' });
  } catch (e) {
    res.status(503).json({ statut: 'degrade', base: 'indisponible', detail: e.message });
  }
});

app.get('/api/version', (req, res) => {
  res.json({ application: 'ShopLab', version: config.version, environnement: config.env });
});

// --- Catalogue ------------------------------------------------------------------
app.get('/api/produits', async (req, res, next) => {
  try {
    const { rows } = await pool.query(
      `SELECT p.id, p.reference, p.nom, c.nom AS categorie, p.prix_ttc, p.stock
         FROM produits p JOIN categories c ON c.id = p.categorie_id
        WHERE p.actif = true ORDER BY p.reference`
    );
    res.json(rows);
  } catch (e) { next(e); }
});

// --- Commandes ------------------------------------------------------------------
app.get('/api/commandes', async (req, res, next) => {
  try {
    const params = [];
    let filtre = '';
    if (req.query.statut) { params.push(req.query.statut); filtre = 'WHERE statut = $1'; }
    const { rows } = await pool.query(
      `SELECT numero, client_id, date_commande, statut, mode_livraison, montant_total
         FROM commandes ${filtre} ORDER BY date_commande DESC LIMIT 100`, params);
    res.json(rows);
  } catch (e) { next(e); }
});

app.get('/api/commandes/:numero', async (req, res, next) => {
  try {
    const { rows } = await pool.query('SELECT * FROM commandes WHERE numero = $1', [req.params.numero]);
    if (!rows.length) return res.status(404).json({ erreur: 'Commande introuvable' });
    const cmd = rows[0];
    const lignes = await pool.query(
      `SELECT l.produit_id, p.reference, p.nom, l.quantite, l.prix_unitaire
         FROM lignes_commande l JOIN produits p ON p.id = l.produit_id WHERE l.commande_id = $1 ORDER BY l.id`, [cmd.id]);
    const paiements = await pool.query('SELECT date_paiement, montant, moyen, statut FROM paiements WHERE commande_id = $1 ORDER BY id', [cmd.id]);
    const historique = await pool.query('SELECT ancien_statut, nouveau_statut, date_changement FROM historique_statuts WHERE commande_id = $1 ORDER BY id', [cmd.id]);
    res.json({ ...cmd, lignes: lignes.rows, paiements: paiements.rows, historique: historique.rows });
  } catch (e) { next(e); }
});

// Creation d'une commande : { client_id, mode_livraison, code_promo?, lignes: [{ produit_id, quantite }] }
app.post('/api/commandes', async (req, res, next) => {
  const client = await pool.connect();
  try {
    const { client_id, mode_livraison, code_promo, lignes } = req.body || {};
    if (!FRAIS.hasOwnProperty(mode_livraison)) throw new ErreurMetier('Mode de livraison invalide', 400);
    if (!Array.isArray(lignes) || lignes.length === 0) throw new ErreurMetier('La commande doit contenir au moins une ligne', 400);

    await client.query('BEGIN');
    const cli = await client.query("SELECT id FROM clients WHERE id = $1 AND statut = 'ACTIF'", [client_id]);
    if (!cli.rows.length) throw new ErreurMetier('Client inexistant ou inactif');

    let montantProduits = 0;
    const detail = [];
    for (const l of lignes) {
      if (!Number.isInteger(l.quantite) || l.quantite < 1 || l.quantite > 10) // RG04
        throw new ErreurMetier(`Quantite invalide pour le produit ${l.produit_id} (1 a 10)`);
      const p = await client.query('SELECT id, prix_ttc, stock FROM produits WHERE id = $1 AND actif = true FOR UPDATE', [l.produit_id]);
      if (!p.rows.length) throw new ErreurMetier(`Produit ${l.produit_id} inexistant ou inactif`);
      if (p.rows[0].stock < l.quantite) throw new ErreurMetier(`Stock insuffisant pour le produit ${l.produit_id}`); // RG10
      montantProduits += Number(p.rows[0].prix_ttc) * l.quantite;
      detail.push({ ...l, prix: p.rows[0].prix_ttc });
    }
    montantProduits = arrondi(montantProduits);

    let promo = null;
    if (code_promo) { // RG05
      const r = await client.query(
        `SELECT * FROM codes_promo WHERE code = $1 AND actif = true
            AND current_date BETWEEN date_debut AND date_fin AND montant_minimum <= $2`, [code_promo, montantProduits]);
      if (!r.rows.length) throw new ErreurMetier('Code promo non applicable');
      promo = r.rows[0];
    }
    const remise = calculerRemise(promo, montantProduits);
    const frais = calculerFrais(mode_livraison, montantProduits);
    const total = arrondi(montantProduits - remise + frais);

    const adr = mode_livraison === 'RETRAIT' ? null
      : (await client.query('SELECT id FROM adresses WHERE client_id = $1 ORDER BY par_defaut DESC, id LIMIT 1', [client_id])).rows[0]?.id;
    if (mode_livraison !== 'RETRAIT' && !adr) throw new ErreurMetier('Aucune adresse de livraison pour ce client');

    const seq = await client.query("SELECT nextval(pg_get_serial_sequence('commandes', 'id')) AS id");
    const id = Number(seq.rows[0].id);
    const numero = `CMD-${new Date().getFullYear()}-${String(id).padStart(5, '0')}`;
    await client.query(
      `INSERT INTO commandes (id, numero, client_id, adresse_livraison_id, statut, mode_livraison, code_promo_id,
                              montant_produits, remise, frais_livraison, montant_total)
       VALUES ($1, $2, $3, $4, 'CREEE', $5, $6, $7, $8, $9, $10)`,
      [id, numero, client_id, adr, mode_livraison, promo ? promo.id : null, montantProduits, remise, frais, total]);
    for (const d of detail) {
      await client.query('INSERT INTO lignes_commande (commande_id, produit_id, quantite, prix_unitaire) VALUES ($1, $2, $3, $4)',
        [id, d.produit_id, d.quantite, d.prix]);
      await client.query('UPDATE produits SET stock = stock - $1 WHERE id = $2', [d.quantite, d.produit_id]);
    }
    await client.query("INSERT INTO historique_statuts (commande_id, ancien_statut, nouveau_statut) VALUES ($1, NULL, 'CREEE')", [id]);
    await client.query('COMMIT');
    res.status(201).json({ numero, montant_produits: montantProduits, remise, frais_livraison: frais, montant_total: total });
  } catch (e) {
    await client.query('ROLLBACK').catch(() => {});
    next(e);
  } finally {
    client.release();
  }
});

// Changement de statut : { statut } - RG06
app.post('/api/commandes/:numero/statut', async (req, res, next) => {
  try {
    const { statut } = req.body || {};
    const { rows } = await pool.query('SELECT id, statut FROM commandes WHERE numero = $1', [req.params.numero]);
    if (!rows.length) return res.status(404).json({ erreur: 'Commande introuvable' });
    const actuel = rows[0].statut;
    if (!(TRANSITIONS[actuel] || []).includes(statut))
      throw new ErreurMetier(`Transition interdite : ${actuel} -> ${statut}`);
    await pool.query('UPDATE commandes SET statut = $1 WHERE id = $2', [statut, rows[0].id]);
    await pool.query('INSERT INTO historique_statuts (commande_id, ancien_statut, nouveau_statut) VALUES ($1, $2, $3)', [rows[0].id, actuel, statut]);
    res.json({ numero: req.params.numero, ancien_statut: actuel, nouveau_statut: statut });
  } catch (e) { next(e); }
});

// --- Gestion des erreurs -----------------------------------------------------
app.use((err, req, res, next) => {
  if (err instanceof ErreurMetier) return res.status(err.code).json({ erreur: err.message });
  console.error(err);
  res.status(500).json({ erreur: 'Erreur interne' });
});

app.listen(config.port, () => {
  console.log(`ShopLab ${config.version} (${config.env}) a l'ecoute sur le port ${config.port}`);
});
