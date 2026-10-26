import os
# L'appli lit la variable d'environnement PORT.
# Si elle existe, elle utilise sa valeur, sinon 8080 par défaut.
bind = f"0.0.0.0:{os.getenv('PORT', '8080')}"
workers = 2
threads = 2
accesslog = "-"
errorlog = "-"
