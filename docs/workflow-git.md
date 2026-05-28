# Workflow Git et GitHub

Ce document décrit un flux simple pour travailler proprement sans modifier directement `master`.

## Principe

- `master` représente la version stable du dépôt.
- Une branche sert à tester une modification isolée.
- Un commit enregistre un état cohérent.
- Un push envoie la branche sur GitHub.
- Une Pull Request permet de relire avant d'intégrer dans `master`.

## Routine conseillée

```bash
git switch master
git pull
git switch -c nom-de-branche
make check
```

Faire ensuite les modifications, puis vérifier :

```bash
make check
git status
git diff
```

Si le résultat est correct :

```bash
git add .
git commit -m "Message clair et court"
git push origin nom-de-branche
```

## Avant une Pull Request

Lancer la validation complète si Docker et Ansible sont disponibles :

```bash
make check-full
```

Puis ouvrir une Pull Request depuis GitHub.

## Conflits Git

Pendant un merge, Git ajoute parfois des marqueurs comme `<<<<<<< HEAD`, `=======` et `>>>>>>> nom-de-branche`.

La partie entre `<<<<<<< HEAD` et `=======` correspond à ta branche actuelle. La partie entre `=======` et `>>>>>>> nom-de-branche` correspond à la branche que tu intègres. Cela veut dire que Git ne sait pas quelle version garder. Il faut modifier le fichier pour produire une seule version finale, puis marquer le conflit comme résolu :

```bash
git add fichier-en-conflit
git commit
```

Ne jamais committer un fichier qui contient encore `<<<<<<<`, `=======` ou `>>>>>>>`.

## Authentification GitHub

Pour éviter de saisir un identifiant à chaque push avec HTTPS :

```bash
gh auth login
gh auth setup-git
```

Vérification :

```bash
gh auth status
```
