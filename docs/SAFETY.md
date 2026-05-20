# Sécurité et précautions

## Risques de `autoremove`
`autoremove` peut supprimer des dépendances jugées inutiles. Sur des systèmes modifiés manuellement, cela peut casser des workflows. Les scripts demandent une confirmation explicite.

## Risques de mise à jour kernel/driver
Les mises à jour kernel, drivers graphiques, firmware et microcode peuvent nécessiter un redémarrage et parfois introduire des régressions matérielles.

## Pourquoi faire un backup/snapshot
Une mise à jour peut échouer (coupure réseau, conflit de dépendances, disque plein). Un snapshot ou backup permet un retour arrière maîtrisé.

## Pourquoi snapshot avant VM RHEL
Le wrapper libvirt tente un snapshot externe avant la mise à jour. Sans snapshot, un rollback rapide est plus difficile.

## Un snapshot n'est pas un backup complet
Un snapshot dépend du stockage source et n'est pas une copie hors site. Garder aussi une stratégie de sauvegarde complète (fichiers + configuration + tests de restauration).
