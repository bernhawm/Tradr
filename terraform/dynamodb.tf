resource "aws_dynamodb_table" "users_collections" {
  name           = "UsersCollections"
  billing_mode   = "PAY_PER_REQUEST"

  hash_key       = "userId"

  attribute {
    name = "userId"
    type = "S"
  }

  tags = {
    Environment = "dev"
    Project     = "CardCollectionApp"
  }
}



# Dynamo DB data
  resource "aws_dynamodb_table_item" "user_123" {
    table_name = aws_dynamodb_table.users_collections.name
    hash_key   = "userId"

    item = jsonencode({
      userId     = { S = "user-123" }
      collections = {
        L = [
          {
            M = {
              collectionId   = { S = "col-001" }
              collectionName = { S = "Main Collection" }
              cards = {
                L = [
                  {
                    M = {
                      cardId   = { S = "0003aa31-d42e-4972-9fb9-086aefe29a2c" }
                      quantity = { N = "3" }
                      name     = { S = "Birds of Paradise" }
                      foil     = { BOOL = false }
                    }
                  },
                  {
                    M = {
                      cardId   = { S = "0016ea50-4f77-4814-a505-8067ecb177cc" }
                      quantity = { N = "2" }
                      name     = { S = "Temporal Manipulation" }
                      foil     = { BOOL = true }
                    }
                  }
                ]
              }
            }
          },
          {
            M = {
              collectionId   = { S = "col-002" }
              collectionName = { S = "Trade Binder" }
              cards = {
                L = [
                  {
                    M = {
                      cardId   = { S = "00372c7a-2e83-4a26-9642-0d092dfcf861" }
                      quantity = { N = "1" }
                      name     = { S = "Eldrazi Temple" }
                      foil     = { BOOL = false }
                    }
                  },
                  {
                    M = {
                      cardId   = { S = "b77dcee1-f42e-4c9d-b6b7-6d5885826060" }
                      quantity = { N = "1" }
                      name     = { S = "Oracle of the Alpha" }
                      foil     = { BOOL = true }
                    }
                  },
                  {
                    M = {
                      cardId   = { S = "5a210b32-6e1f-4578-bd8b-4e481b761159" }
                      quantity = { N = "1" }
                      name     = { S = "Izoni, Thousand-Eyed" }
                      foil     = { BOOL = true }
                    }
                  }
                ]
              }
            }
          }
        ]
      }
    })
  }

  resource "aws_dynamodb_table_item" "user_456" {
    table_name = aws_dynamodb_table.users_collections.name
    hash_key   = "userId"

    item = jsonencode({
      userId     = { S = "user-456" }
      collections = {
        L = [
          {
            M = {
              collectionId   = { S = "col-003" }
              collectionName = { S = "Main Collection" }
              cards = {
                L = [
                  {
                    M = {
                      cardId   = { S = "0003aa31-d42e-4972-9fb9-086aefe29a2c" }
                      quantity = { N = "3" }
                      name     = { S = "Birds of Paradise" }
                      foil     = { BOOL = false }
                    }
                  },
                  {
                    M = {
                      cardId   = { S = "0016ea50-4f77-4814-a505-8067ecb177cc" }
                      quantity = { N = "2" }
                      name     = { S = "Temporal Manipulation" }
                      foil     = { BOOL = true }
                    }
                  }
                ]
              }
            }
          },
          {
            M = {
              collectionId   = { S = "col-004" }
              collectionName = { S = "Trade Binder" }
              cards = {
                L = [
                  {
                    M = {
                      cardId   = { S = "00372c7a-2e83-4a26-9642-0d092dfcf861" }
                      quantity = { N = "1" }
                      name     = { S = "Eldrazi Temple" }
                      foil     = { BOOL = false }
                    }
                  },
                  {
                    M = {
                      cardId   = { S = "b77dcee1-f42e-4c9d-b6b7-6d5885826060" }
                      quantity = { N = "1" }
                      name     = { S = "Oracle of the Alpha" }
                      foil     = { BOOL = true }
                    }
                  },
                  {
                    M = {
                      cardId   = { S = "5a210b32-6e1f-4578-bd8b-4e481b761159" }
                      quantity = { N = "1" }
                      name     = { S = "Izoni, Thousand-Eyed" }
                      foil     = { BOOL = true }
                    }
                  }
                ]
              }
            }
          }
        ]
      }
    })
  }

#RDS Data
