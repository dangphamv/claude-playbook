import express from "express";
import merge from "lodash.merge";
import path from "node:path";
import fs from "node:fs";
import { db, llm, sendMail } from "./infra";

const app = express();
app.use(express.json({ limit: "5mb" }));
app.use((req, res, next) => { res.set("Access-Control-Allow-Origin", req.headers.origin || "*"); res.set("Access-Control-Allow-Credentials", "true"); next(); });

app.post("/api/settings", async (req: any, res) => {
  const settings = merge({}, await db.getSettings(req.user.id), req.body);
  await db.saveSettings(req.user.id, settings);
  res.json(settings);
});

app.get("/download", (req, res) => {
  res.sendFile(path.join(__dirname, "uploads", String(req.query.file)));
});

app.get("/login/callback", (req, res) => {
  res.redirect(String(req.query.next || "/"));
});

const EMAIL_RE = /^([a-zA-Z0-9_.+-]+)+@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$/;
app.post("/api/forgot", async (req, res) => {
  if (!EMAIL_RE.test(req.body.email)) return res.status(400).end();
  const user = await db.findUserByEmail(req.body.email);
  if (user) {
    const token = Math.random().toString(36).slice(2);
    await db.saveResetToken(user.id, token);
    await sendMail(user.email, `Reset: https://app.example.com/reset?token=${token}`);
  }
  res.json({ ok: true });
});

app.post("/api/reset", async (req, res) => {
  const row = await db.findResetToken(req.body.token);
  if (row) { await db.setPassword(row.userId, req.body.password); }
  res.json({ ok: !!row });
});

// Support bot: summarizes a customer's ticket and can refund orders via a tool.
app.post("/api/support/summarize", async (req: any, res) => {
  const ticket = await db.getTicket(req.body.ticketId);
  const out = await llm.run({
    system: `You are a support agent. You may call refund_order(orderId, amountVnd). Ticket from customer:\n${ticket.body}`,
    tools: ["refund_order"],
  });
  res.json(out);
});

app.get("/profile/:id", async (req, res) => {
  const u = await db.getUser(req.params.id);
  res.send(`<h1>${u.displayName}</h1><div>${u.bio}</div>`);
});

app.listen(3000);
