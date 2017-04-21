require 'classifier-reborn'
require 'natto'
require 'csv'

TYPE_NORMAL = "Normal"
TYPE_SPAM   = "Spam"

class App
  attr_reader :classifier, :natto

  def initialize
    @classifier = ClassifierReborn::Bayes.new TYPE_NORMAL, TYPE_NORMAL
    @natto = Natto::MeCab.new
    train
  end

  def execute
    while str = STDIN.gets do
      break if str.chomp == "exit"
      puts classifier.classify wakachigaki(str)
    end
  end

  def execute_from_csv
    spam = []
    normal = []

    CSV.foreach("data.csv") do |row|
      if (classifier.classify(wakachigaki(row[0])) == TYPE_SPAM)
        spam << [row[0]]
      else
        normal << [row[0]]
      end
    end

    dump_to_csv("spam.csv", spam)
    dump_to_csv("normal.csv", normal)
  end

  def dump
    classifier_snapshot = Marshal.dump classifier
    File.open("classifier.dat", "w") {|f| f.write(classifier_snapshot) }
  end

  private

  def dump_to_csv(file_name, data)
    CSV.open(file_name, "w") do |f|
      data.each do |d|
        f << d
      end
  end

  def train
    CSV.foreach("train.csv") do |row|
      type = row[0].nil? ? TYPE_NORMAL : TYPE_SPAM
      classifier.train type, wakachigaki(row[1])
      classifier.train type, row[1]
    end
  end

  def wakachigaki(text)
    goiken = []
    natto.parse(text) do |n|
      goiken << n.surface
    end
    goiken.join(' ')
  end
end

App.new.dump
