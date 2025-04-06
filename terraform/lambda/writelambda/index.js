const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");
const {
  DynamoDBDocumentClient,
  UpdateCommand
} = require("@aws-sdk/lib-dynamodb");

const client = new DynamoDBClient({});
const docClient = DynamoDBDocumentClient.from(client);
const TABLE_NAME = process.env.TABLE_NAME;

exports.handler = async (event) => {
  try {
    const body = JSON.parse(event.body);
    const { userId, collection } = body;

    if (!userId || !collection || !collection.collectionId) {
      return {
        statusCode: 400,
        body: JSON.stringify({ error: "Missing userId or collection data" }),
      };
    }

    const params = {
      TableName: TABLE_NAME,
      Key: { userId },
      UpdateExpression: "SET collections = list_append(if_not_exists(collections, :emptyList), :newCollection)",
      ExpressionAttributeValues: {
        ":newCollection": [collection],
        ":emptyList": []
      },
      ReturnValues: "UPDATED_NEW"
    };

    const result = await docClient.send(new UpdateCommand(params));

    return {
      statusCode: 200,
      body: JSON.stringify({ message: "Collection added", result }),
    };

  } catch (err) {
    console.error("Error adding collection:", err);
    return {
      statusCode: 500,
      body: JSON.stringify({ error: "Internal Server Error", details: err.message }),
    };
  }
};
