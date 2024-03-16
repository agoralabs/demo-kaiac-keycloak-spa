import express from 'express';
import stringReplace from 'string-replace-middleware';
import dotenv from 'dotenv/config';

const app = express();
const port = process.env.SPA_PORT;

app.use(stringReplace({
  KC_URL: process.env.KC_URL || "http://localhost:8180"
}));

app.use('/', express.static('public'));

app.listen(port, () => {
  console.log(`Listening on port ${port}.`);
});
