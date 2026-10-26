import os

#l'appli lit une variable d'environnement appelée PORT. Si elle existe, elle utilise sa valeur, sinon elle prend 8080 par défaut. 
bind = f"0.0.0.0:{os.getenv('PORT', '8080')}"
workers = 2
threads = 2
accesslog = "-"
errorlog = "-"
