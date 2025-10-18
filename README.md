# Installation OVH VPS <!-- omit in toc -->

- [Premières étapes](#premières-étapes)
  - [Première connexion](#première-connexion)
  - [Connexion en SSH](#connexion-en-ssh)
  - [Mise à jour initiale](#mise-à-jour-initiale)
- [Configuration du VPS](#configuration-du-vps)
  - [Variables Ansible du VPS](#variables-ansible-du-vps)
- [Vintage Story](#vintage-story)
  - [Installation](#installation)
  - [Service Management](#service-management)
  - [Désinstallation](#désinstallation)

## Premières étapes

### Première connexion

Suivre la première vidéo de cet article [Premiers pas avec un VPS].

1. Première connexion --> Demande de changement du mot de passe
2. Reconnexion au VPS avec le nouveau mot de passe
3. Sauvegarder le mot de passe dans un coffre fort pour ne pas le perdre
4. Changement du port SSH

   ```shell
   sudo vim /etc/ssh/sshd_config
   # Modifier "ClientAliveInterval" 120 par 300 - Ping toutes les 5 minutes
   # Modifier "ClientAliveCountMax" 3 par 2 - Ferme après 2 pings sans réponse (soit 10 minutes)
   # Modifier "LoginGraceTime" 2m par 30 - Temps pour se connecter avant déconnexion
   # Modifier "MaxAuthTries" 6 par 3 - Nombre de tentatives de connexion avant déconnexion
   # Modifier "Port" 22 par un port entre 49152 et 65535 - Port SSH personnalisé (plus sécurisé)
   ```

5. Redémarrage du VPS pour qu'il tienne compte du changement du nouveau port

   ```shell
   sudo reboot
   ```

### Connexion en SSH

Suivre cet article [Comment créer et utiliser des clés d'authentification pour les connexions SSH aux serveurs OVHcloud].

1. Créer en local (machine hôte) la clé SSH.

   ```shell
   ssh-keygen -t ed25519 -a 100
   # La nommer "ovh-vps"
   ```

   Afficher la clé SSH publique.

   ```shell
   cat ~/.ssh/ovh-vps.pub
   ```

2. Créer le fichier `.ssh/config` avec le contenu suivant

   ```shell
   # OVH VPS
   Host ovh-vps
     HostName X.X.X.X
     Port YYYYY
     User debian
     IdentityFile ~/.ssh/ovh-vps
   ```

   Remplacer `X.X.X.X` par l'IP publique du VPS.

   Remplacer `YYYYY` par le port SSH.

3. A cette étape, il est possible de se connecter avec la commande `ssh ovh-vps`.

   Le mot de passe sera demandé car la clé SSH reste inconnue.

4. Se connecter au VPS

   Copier le contenu de la clé SSH publique dans `~/.ssh/authorized_keys`

   Désormais, il est possible de se connecter sans avoir à saisir le mot de passe.

### Mise à jour initiale

1. Mettre à jour le VPS

   ```shell
   sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y
   ```

2. Installer Git et Ansible

   ```shell
   sudo apt install git ansible -y
   ```

   Git pour cloner ce _repository_ qui contient le playbook Ansible.

   Ansible pour automatiser la configuration du VPS.

## Configuration du VPS

```shell
# Installer les collections Ansible nécessaires
ansible-galaxy collection install -r ansible/requirements.yml

# Lancer le playbook de configuration du VPS
ansible-playbook -i ansible/inventory.ini ansible/playbook-vps-setup.yml
```

### Variables Ansible du VPS

Fichier : `ansible/vars/production.yml`

```shell
# Variables d'environnement pour le développement/test

# Configuration du serveur VPS
vps_ip: X.X.X.X # IP publique du serveur
vps_ssh_port: YYYY # Port SSH par défaut

```

## Vintage Story

### Installation

```shell
# Lancer le playbook d'installation de Vintage Story
ansible-playbook -i ansible/inventory.ini ansible/playbook-vintage-story.yml
```

### Service Management

```shell
# Démarrer le serveur Vintage Story
sudo systemctl start vintage-story

# Arrêter le serveur Vintage Story
sudo systemctl stop vintage-story

# Redémarrer le serveur Vintage Story
sudo systemctl restart vintage-story

# Vérifier le statut du serveur Vintage Story
sudo systemctl status vintage-story
```

### Désinstallation

```shell
# Lancer le playbook de désinstallation de Vintage Story
ansible-playbook -i ansible/inventory.ini ansible/playbook-vintage-story-cleanup.yml
```

<!-- Links -->

[Premiers pas avec un VPS]: https://help.ovhcloud.com/csm/fr-vps-getting-started?id=kb_article_view&sysparm_article=KB0047736
[Comment créer et utiliser des clés d'authentification pour les connexions SSH aux serveurs OVHcloud]: https://help.ovhcloud.com/csm/fr-dedicated-servers-creating-ssh-keys?id=kb_article_view&sysparm_article=KB0043385
