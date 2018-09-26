require('pg')

class PizzaOrder

  attr_reader :id
  attr_accessor :first_name, :last_name, :topping, :quantity

  def initialize(options)
    @id = options['id'].to_i()
    @first_name = options['first_name']
    @last_name = options['last_name']
    @topping = options['topping']
    @quantity = options['quantity'].to_i()
  end

  def self.delete_all()
    db = PG.connect({
      dbname: 'pizza_shop',
      host: 'localhost'
    })
    sql = "DELETE FROM pizza_orders;"
    db.exec(sql)
    db.close()
  end

def self.all()
  db = PG.connect({dbname: 'pizza_shop', host: 'localhost'})

  sql = 'SELECT * FROM pizza_orders;'
  db.prepare('all', sql)
  order_hashes = db.exec_prepared('all')
  db.close()

  order_objects = order_hashes.map {|order_hash| PizzaOrder.new(order_hash)}

  return order_objects
end

  def save()
    db = PG.connect({
      dbname: 'pizza_shop',
      host: 'localhost'
    })

    sql = "
      INSERT INTO pizza_orders (first_name, last_name, topping, quantity)
      VALUES ($1, $2, $3, $4)
      RETURNING id;
    "

    db.prepare('save', sql)
    result = db.exec_prepared('save', [@first_name, @last_name, @topping, @quantity])  # prepared statement - protects against sql injection
    db.close()

    result_hash = result[0]
    string_id = result_hash['id']
    id = string_id.to_i()
    @id = id
  end

  def update()
    db = PG.connect({
      dbname: 'pizza_shop',
      host: 'localhost'
    })
    sql = "
      UPDATE pizza_orders
      SET (first_name, last_name, topping, quantity) = ($1, $2, $3, $4)
      WHERE id = $5;
    "

    values = [@first_name, @last_name, @topping, @quantity, @id]
    db.prepare('update', sql)
    db.exec_prepared('update', values)
    db.close()

  end

end
