class Dog

attr_accessor :id, :name, :breed

@@all = []

  def initialize(id: id=nil, name: name, breed: breed)
    @id = id
    @name =  name
    @breed = breed
    @@all << self
  end

  def self.create_table
    sql = <<-SQL
      CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      );
    SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
      DROP TABLE dogs;
    SQL

    DB[:conn].execute(sql)
  end

  def save
    #Save the instance of the dog into the database, and update it with an id from the DB.
    sql = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
    self
  end

  def self.create(attributes)
    #create instance of dog and in database using the arguments.
    new_dog=Dog.new(attributes)
    new_dog.save
  end

  def self.find_by_id(id)
    #Find dog by id
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
    SQL
    array = DB[:conn].execute(sql, id)[0]
    Dog.new(id: array[0], name: array[1], breed: array[2])
  end

  def self.find_or_create_by(attributes)
    #search database for dog, if name and breed match, create instance of dog from DB details, otherwise create new dog in database as well as new instance
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? AND breed = ?;
    SQL
    array = DB[:conn].execute(sql, attributes[:name], attributes[:breed])[0]
    array
    if array == nil
      Dog.create(attributes)
    else
      Dog.new(id: array[0], name: array[1], breed: array[2])
    end
  end

  def self.new_from_db(row)
    #Add a new instance of a dog, using an array of info
    new_dog = Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.find_by_name(name)
  #Find from database the dog by name, and return it as an object
    sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?;
    SQL
    array = DB[:conn].execute(sql, name)[0]
    Dog.new_from_db(array)
  end

  def update
  #Update dog in database from the instances information
    sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ?
      WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
