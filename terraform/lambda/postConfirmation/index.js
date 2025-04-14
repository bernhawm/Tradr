const { Client } = require("pg");

exports.handler = async (event) => {
  const email = event.request.userAttributes.email;
  const sub = event.request.userAttributes.sub;

  const client = new Client({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    port: 5432,
  });

  try {
    await client.connect();
    const query = `
      INSERT INTO users (cognito_sub, email)
      VALUES ($1, $2)
      ON CONFLICT (email) DO NOTHING
    `;
    await client.query(query, [sub, email]);
    console.log(`User ${email} inserted into DB.`);
  } catch (err) {
    console.error("DB insert failed:", err);
    throw err;
  } finally {
    await client.end();
  }

  return event;
};
