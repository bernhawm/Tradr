const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const {
  DynamoDBDocumentClient,
  GetCommand,
} = require("@aws-sdk/lib-dynamodb");

const { Client } = require("pg"); // PostgreSQL client for RDS

const ddbClient = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(ddbClient);
const TABLE_NAME = "UsersCollections";

// RDS Config (use environment variables in production)
const rdsClient = new Client({
  host: process.env.RDS_HOST,        // e.g., "mydb.123456789012.us-east-1.rds.amazonaws.com"
  port: 5432,
  user: process.env.RDS_USER,
  password: process.env.RDS_PASSWORD,
  database: process.env.RDS_DATABASE,
});

exports.handler = async (event) => {
  const queryParams = event.queryStringParameters || {};
  const mode = queryParams.mode || "collections";

  if (mode === "collections") {
    const userId = event.pathParameters?.userId;

    if (!userId) {
      return {
        statusCode: 400,
        body: JSON.stringify({ message: "Missing userId in path parameters" }),
      };
    }

    try {
      const data = await docClient.send(
        new GetCommand({
          TableName: TABLE_NAME,
          Key: { userId },
        })
      );

      if (!data.Item) {
        return {
          statusCode: 404,
          body: JSON.stringify({ message: "User not found" }),
        };
      }

      return {
        statusCode: 200,
        body: JSON.stringify(data.Item.collections || []),
      };
    } catch (err) {
      console.error("DynamoDB error:", err);
      return {
        statusCode: 500,
        body: JSON.stringify({ message: "Internal server error" }),
      };
    }
  }

  // Fetch all users from RDS
  if (mode === "users") {
    try {
      await rdsClient.connect();

      const result = await rdsClient.query("SELECT * FROM users");
      await rdsClient.end();

      return {
        statusCode: 200,
        body: JSON.stringify(result.rows),
      };
    } catch (err) {
      console.error("RDS error:", err);
      return {
        statusCode: 500,
        body: JSON.stringify({ message: "Error querying RDS database" }),
      };
    }
  }

  // Default fallback if mode is unsupported
  return {
    statusCode: 400,
    body: JSON.stringify({ message: "Invalid mode parameter" }),
  };
};
