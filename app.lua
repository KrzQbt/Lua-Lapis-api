local lapis = require("lapis")
local app = lapis.Application()
local respond_to = require("lapis.application").respond_to
local json_params = require("lapis.application").json_params


local Model = require("lapis.db.model").Model
local schema = require("lapis.db.schema")

local types = schema.types

local ProductTable = Model:extend("product")
local CategoryTable = Model:extend("category")





app:match("/product/:id", respond_to({
  GET = function(self)
    productWithId = ProductTable:find(tonumber(self.params.id))

    return {
            json={
                name = productWithId["name"],
                price = productWithId["price"],
                categoryId = productWithId["categoryId"]
              }
              
            }
  end,


  PUT = json_params(function(self)

    local productWithNameCount = ProductTable:count("name = ?",self.params.name)
    if tonumber(productWithNameCount) ~= 0 then
    return {
      json={
        productWithNameExists = self.params.name
      }
      
      }
   end

    productToUpdate = ProductTable:find(tonumber(self.params.id))
    productToUpdate:update({
      name = self.params.name,
      price = self.params.price,
      categoryId = self.params.categoryId
    })


    return {json={ 
      updated = self.params.id
}} 

  end),
  DELETE = function(self)
    productToDelete = ProductTable:find(tonumber(self.params.id))
    productToDelete:delete()

    return self.params.id
  end
}))

app:match("/product", respond_to({
  

    POST = json_params(function(self)

    local productWithNameCount = ProductTable:count("name = ?",self.params.name)
    if tonumber(productWithNameCount) ~= 0 then
    return {
      json={
        productWithNameExists = self.params.name
      }
      
      }
   end

    local createdProduct = ProductTable:create({
      name = self.params.name,
      price = self.params.price,
      categoryId = self.params.categoryId
    })

    return {
      json={
          newProductId = createdProduct["id"],
          createdName = createdProduct["name"]
        }
        
      }

  end)
}))

app:match("/category/:id", respond_to({

  GET = function(self)
    local productsWithCategoryId = ProductTable:select("where categoryId = ?",tonumber(self.params.id))
    
    return {json={ 
                productsWithCategoryId = productsWithCategoryId
    }} 
  end,


  PUT = json_params(function(self)
    local categoryWithNameCount = CategoryTable:count("name = ?",self.params.name)
    if tonumber(categoryWithNameCount) ~= 0 then
    return {
      json={
        categoryWithNameExists = self.params.name
      }
      
      }
   end

    categoryToUpdate = CategoryTable:find(tonumber(self.params.id))
    categoryToUpdate:update({
      name = self.params.name
    })

    return {json={ 
      updated = self.params.id
}} 

  end),


  DELETE = function(self)
    local productsWithCategoryId = ProductTable:select("where categoryId = ?",tonumber(self.params.id))
    for k, v in pairs(productsWithCategoryId) do
      productToDelete = ProductTable:find(v["id"])
      productToDelete:delete()
    end

    return self.params.id
  end
}))



app:match("/category", respond_to({

  POST = json_params(function(self)

  local categoryWithNameCount = CategoryTable:count("name = ?",self.params.name)
  if tonumber(categoryWithNameCount) ~= 0 then
  return {
    json={
        categoryWithNameExists = self.params.name
      }
      
    }
  end

  local createdCategory = CategoryTable:create({
    name = self.params.name
  })

  return {
    json={
        newCategoryId = createdCategory["id"],
        createdName = createdCategory["name"]
      }
      
    }

end)
}))

return app
