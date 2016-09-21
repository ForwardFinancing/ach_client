class FakeSFTPConnection
  def self.dir
    self
  end

  def self.glob(*args)
    [
      FakeFile.new('ACHP08111605'),
      FakeFile.new('ACHP08111601'),
      FakeFile.new('ACHP08111602')
    ]
  end

  def self.file
    self
  end

  def self.open!(*args, &block)
    if block_given?
      yield FakeFile.new('TestFile')
    else
      self
    end
  end

  def self.read
    'test file contents blah blah blah'
  end

  class FakeFile
    attr_reader :name
    def initialize(name)
      @name = name
    end

    def puts(*)
    end
  end
end
