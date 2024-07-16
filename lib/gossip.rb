
# Requiert les modules Sinatra et CSV pour gérer les requêtes web et les opérations CSV.
require 'sinatra'
require 'csv'

# Définition de la classe Gossip pour encapsuler les données des potins.
class Gossip
  attr_reader :author, :content

  # Initialise une nouvelle instance de Gossip avec un auteur et un contenu.
  def initialize(author, content)
    @author = author
    @content = content
  end

  # Enregistre l'instance de Gossip dans le fichier CSV.
  def save
    CSV.open("db/gossip.csv", "ab", quote_char: '"', force_quotes: true) do |csv|
      csv << [author, content]
    end
  end

  # Récupère tous les potins du fichier CSV.
  def self.all
    all_gossips = []
    CSV.foreach("db/gossip.csv", headers: false, quote_char: '"', col_sep: ',') do |row|
      if row.size == 2
        all_gossips << Gossip.new(row[0], row[1])
      else
        puts "Ligne malformée: #{row.inspect}"
      end
    end
    all_gossips
  end
end

# Route pour gérer la requête de la page d'accueil.
get '/' do
  @gossips = Gossip.all  # Récupère tous les potins et les stocke dans @gossips pour l'affichage.
  erb :index  # Rendu du template de vue index.erb.
end

# Route pour afficher le formulaire d'ajout d'un nouveau potin.
get '/gossips/new' do
  erb :new_gossip  # Rendu du template de vue new_gossip.erb.
end

# Route pour gérer la soumission du formulaire et enregistrer un nouveau potin.
post '/gossips/new' do
  Gossip.new(params["author"], params["content"]).save  # Crée une nouvelle instance de Gossip et l'enregistre.
  redirect '/'  # Redirige vers la page d'accueil pour afficher les potins mis à jour.
end
