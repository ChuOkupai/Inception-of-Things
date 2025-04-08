# IoT Project Part 3: K3d and ArgoCD

Ce dépôt contient les fichiers de configuration pour déployer une application avec ArgoCD dans un cluster K3d.

## Structure du dépôt

- `deployment.yaml`: Définit le déploiement Kubernetes pour l'application
- `service.yaml`: Définit le service Kubernetes pour exposer l'application

## Comment changer la version de l'application

Pour mettre à jour l'application de la version v1 à la version v2, modifiez la ligne suivante dans le fichier `deployment.yaml` :

```yaml
# Changer cette ligne
image: wil42/playground:v1

# En cette ligne
image: wil42/playground:v2
```

Une fois que vous avez effectué cette modification et que vous l'avez poussée vers le dépôt GitHub, ArgoCD détectera automatiquement le changement et mettra à jour l'application dans le cluster Kubernetes.

## Vérification de la version

Pour vérifier quelle version de l'application est en cours d'exécution, vous pouvez utiliser la commande curl suivante :

```bash
curl http://localhost:8888/
```

Cela devrait renvoyer quelque chose comme :
```
{"status":"ok", "message": "v1"}
```

ou 

```
{"status":"ok", "message": "v2"}
```

selon la version actuellement déployée.
