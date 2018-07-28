class Dog

  attr_accessor :id, :name, :breed

  def initialize(id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end

  def self.create(name: name, breed: breed)
      new_dog = Dog.new(name: name, breed: breed)
      new_dog.save
  end

  def self.new_from_db(row)
    new_dog = Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
    sql = <<-SQL
       SELECT *
       FROM dogs
       WHERE name = ?
       SQL
     output = DB[:conn].execute(sql, name)[0]
     new_dog = Dog.new(id:output[0], name:output[1], breed:output[2])
  end


   def self.find_by_id(id)
     sql = <<-SQL
       SELECT *
       FROM dogs
       WHERE id = ?
     SQL
     output = DB[:conn].execute(sql,id)[0]
     new_dog = Dog.new(id: id, name: output[1], breed: output[2])
   end

  def save
    sql = <<-SQL
      INSERT INTO dogs(name, breed)
      VALUES(?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    return self
  end

  def self.find_or_create_by(name:name, breed:breed)
      sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      AND breed = ?
    SQL
    output = DB[:conn].execute(sql, name, breed)
    if !output.empty?
      output = output[0]
      Dog.new(id:output[0], name:output[1], breed:output[2])
    else
      Dog.create(name:name, breed:breed)
    end
  end

  def update
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    output = DB[:conn].execute(sql, name, breed, id)
  end

  def self.drop_table
    sql = "DROP TABLE IF EXISTS dogs"
    DB[:conn].execute(sql)
  end

end
