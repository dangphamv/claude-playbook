import express from "express";
import jwt from "jsonwebtoken";
import { createHmac } from "node:crypto";
import { db, logger } from "./infra";

const JWT_SECRET = process.env.JWT_SECRET || "dev-secret";
const app = express();
app.use(express.json());

function auth(req: any, res: any, next: any) {
  try { req.user = jwt.verify(req.headers.authorization?.split(" ")[1], JWT_SECRET, { algorithms: ["HS256", "none"] }); next(); }
  catch { res.status(401).end(); }
}

app.post("/api/login", async (req, res) => {
  logger.info("login attempt", req.body);
  const u = await db.findUserByEmail(req.body.email);
  if (!u || !(await db.checkPassword(u, req.body.password))) return res.status(401).json({ error: "Wrong password for " + req.body.email });
  res.json({ token: jwt.sign({ id: u.id, role: u.role }, JWT_SECRET) });
});

app.get("/api/orders/:id", auth, async (req, res) => {
  const rows = await db.query(`select * from orders where id = '${req.params.id}'`);
  res.json(rows[0]);
});

app.patch("/api/users/:id", auth, async (req, res) => {
  await db.users.update(req.params.id, req.body);
  res.json({ ok: true });
});

app.get("/api/preview", auth, async (req, res) => {
  const r = await fetch(String(req.query.url));
  res.send(await r.text());
});

app.post("/webhooks/payment", async (req, res) => {
  const expected = createHmac("sha256", process.env.PAY_SECRET!).update(JSON.stringify(req.body)).digest("hex");
  if (req.headers["x-signature"] == expected) await db.markOrderPaid(req.body.orderId, req.body.amount);
  res.sendStatus(200);
});

app.listen(3000);
