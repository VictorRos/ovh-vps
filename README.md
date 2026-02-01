# Installation OVH VPS <!-- omit in toc -->

- [Premières étapes](#premières-étapes)
  - [Première connexion](#première-connexion)
  - [Connexion en SSH](#connexion-en-ssh)
- [Configuration de la machine hôte](#configuration-de-la-machine-hôte)
- [Configuration du VPS](#configuration-du-vps)
  - [Variables Ansible du VPS](#variables-ansible-du-vps)
- [Vintage Story](#vintage-story)
  - [Variables Ansible de Vintage Story](#variables-ansible-de-vintage-story)
  - [Installation](#installation)
  - [Service Management](#service-management)
  - [Désinstallation](#désinstallation)
- [Minecraft](#minecraft)
  - [Variables Ansible de Minecraft](#variables-ansible-de-minecraft)
  - [Installation](#installation-1)
  - [Gestion du serveur](#gestion-du-serveur)
  - [Limitations connues de RCON](#limitations-connues-de-rcon)
  - [Désinstallation](#désinstallation-1)

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

## Configuration de la machine hôte

Il est nécessaire d'installer les prérequis sur la machine hôte (locale) pour configurer ensuite le VPS.

Ce script met à jours les paquets et installe les dépendances nécessaires pour exécuter les playbooks Ansible.

```shell
bash scripts/prerequisites.sh
```

## Configuration du VPS

```shell
# Installer les collections Ansible nécessaires
ansible-galaxy collection install -r ansible/requirements.yml

# Lancer le playbook de configuration du VPS
ansible-playbook --extra-vars @ansible/vars/production.yml -i ansible/inventory.yml ansible/playbook-vps-setup.yml
```

### Variables Ansible du VPS

Fichier : `ansible/vars/production.yml`

```shell
# Variables d'environnement pour le développement/test

# Variables globales pour la connexion SSH (utilisées par tous les playbooks)
vps_ip: X.X.X.X # IP publique du serveur
vps_ssh_port: YYYY # Port SSH par défaut

```

## Vintage Story

### Variables Ansible de Vintage Story

Fichier : `ansible/vars/production.yml`

```shell
# Configuration réseau Vintage Story
vintage_story_server_ip: X.X.X.X # IP publique du serveur
vintage_story_port: YYYY # Port du serveur

```

### Installation

```shell
# Lancer le playbook d'installation de Vintage Story
ansible-playbook --extra-vars @ansible/vars/production.yml -i ansible/inventory.yml ansible/playbook-vintage-story.yml
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
ansible-playbook --extra-vars @ansible/vars/production.yml -i ansible/inventory.yml ansible/playbook-vintage-story-cleanup.yml
```

## Minecraft

### Variables Ansible de Minecraft

Fichier : `ansible/vars/production.yml`

```shell
# Configuration réseau Minecraft
minecraft_server_ip: X.X.X.X # IP publique du serveur
minecraft_port: 25565 # Port du serveur (par défaut)
minecraft_rcon_password: '' # Optionnel : si vide, un mot de passe sera généré automatiquement
```

### Installation

```shell
# Lancer le playbook d'installation de Minecraft avec Fabric
ansible-playbook --extra-vars @ansible/vars/production.yml -i ansible/inventory.yml ansible/playbook-minecraft.yml
```

### Gestion du serveur

Le rôle Minecraft installe des alias et fonctions pour faciliter la gestion du serveur. Connectez-vous en tant qu'utilisateur `minecraft` pour les utiliser :

```shell
# Démarrer le serveur
server-start

# Arrêter le serveur
server-stop

# Redémarrer le serveur
server-restart

# Vérifier le statut du serveur
server-status

# Envoyer une commande au serveur via RCON
server-console "list"
server-console "whitelist list"
server-console "op NomDuJoueur"
server-console "deop NomDuJoueur"
server-console "stop"

# Mode interactif RCON (pour les commandes avec réponses longues)
server-console
# Puis tapez vos commandes dans le terminal interactif

# Afficher les logs du serveur
server-logs
```

**Note importante** : Les alias `server-start`, `server-stop`, `server-restart`, et `server-status` utilisent `systemctl` directement. `server-console` et `server-logs` utilisent le script `server.sh` qui gère RCON.

### Limitations connues de RCON

Le client RCON utilisé (`mcrcon`) a des limitations connues avec les serveurs Fabric :

- **Réponses fragmentées** : Les commandes avec des réponses très longues (comme `/help`) peuvent ne pas fonctionner correctement à cause d'un problème de fragmentation des paquets RCON.
- **Messages d'erreur tronqués** : Certains messages d'erreur peuvent être incomplets.

**Solutions alternatives** :
- Pour les commandes avec beaucoup de sortie, utilisez le mode interactif : `server-console` (sans arguments)
- Pour voir les réponses complètes, consultez les logs : `server-logs`
- Pour la whitelist, modifiez directement `/var/games/minecraft/data/whitelist.json` puis utilisez `server-console "whitelist reload"`
- Pour les opérateurs (admins), modifiez directement `/var/games/minecraft/data/ops.json`

### Désinstallation

```shell
# Lancer le playbook de désinstallation de Minecraft
ansible-playbook --extra-vars @ansible/vars/production.yml -i ansible/inventory.yml ansible/playbook-minecraft-cleanup.yml
```

**Note** : Par défaut, le cleanup préserve les mondes dans `/var/games/minecraft/data/worlds/`, ainsi que `whitelist.json`, `banned-ips.json`, et `banned-players.json` pour permettre une réinstallation ultérieure sans perdre les données.

<!-- Links -->

[Premiers pas avec un VPS]: https://help.ovhcloud.com/csm/fr-vps-getting-started?id=kb_article_view&sysparm_article=KB0047736
[Comment créer et utiliser des clés d'authentification pour les connexions SSH aux serveurs OVHcloud]: https://help.ovhcloud.com/csm/fr-dedicated-servers-creating-ssh-keys?id=kb_article_view&sysparm_article=KB0043385
