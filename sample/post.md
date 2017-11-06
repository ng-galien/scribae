![Texte alternatif](http://pas-wordpress-media.s3.amazonaws.com/content/uploads/2015/09/shutterstock_123670585.jpg "texte pour le titre, facultatif")

# Edition des articles

Les articles sont rédigés en langage markdown.

# Markdown

> Article recopié de Wikipédia

Markdown est un langage de balisage léger créé par John Gruber en 2004. Son but est d'offrir une syntaxe facile à lire et à écrire. Un document balisé par Markdown peut être lu en l'état sans donner l’impression d'avoir été balisé ou formaté par des instructions particulières.

Un document balisé par Markdown peut être converti facilement en HTML. Bien que la syntaxe Markdown ait été influencée par plusieurs filtres de conversion de texte existants vers HTML — dont Setext1, atx2, Textile, reStructuredText, Grutatext3 et EtText4 —, la source d’inspiration principale est le format du courrier électronique en mode texte.

## Quelques exemples

Voici quelques exemples de syntaxe Markdown. Quelques balises HTML équivalentes sont données.
Cette liste n'est pas exhaustive.

## Formatage

Pour mettre du texte en emphase, ce qui produit une mise en italique dans un navigateur courant :

*quelques mots* ou  _quelques mots_

```
*quelques mots* ou  _quelques mots_
```

---

Pour mettre du texte en grande emphase, ce qui produit une mise en gras dans un navigateur courant :

**plus important**

```
**plus important**
```

---

Pour mettre du code dans le texte:

Mon texte `code` fin de mon texte

```
Mon texte `code` fin de mon texte
```

---

Pour un paragraphe de code, mettre quatre espaces devant :

    Première ligne de code
    Deuxième ligne

```
    Première ligne de code
    Deuxième ligne
```

---

Comme dans les courriels, il est possible de faire des citations :

> Ce texte apparaîtra dans un élément HTML.

```
> Ce texte apparaîtra dans un élément HTML.
```

---

Pour faire un nouveau paragraphe, sauter une ligne

Premier paragraphe

Deuxième paragraphe

```
Premier paragraphe

Deuxième paragraphe
```

---

Pour faire un simple retour à la ligne, mettre deux espaces en fin de ligne.

---

## Listes

Sauter une ligne avant le début de la liste.

Pour créer une liste non ordonnée:

* Pommes
* Poires
    * Sous élément avec au moins quatre espaces devant.

```
* Pommes
* Poires
    * Sous élément avec au moins quatre espaces devant.
```

---

Et une liste ordonnée:

1. mon premier
2. mon deuxième

```
1. mon premier
2. mon deuxième
```

---

Et une liste en mode case à cocher

- [ ] Case non cochée
- [x] Case cochée

```
- [ ] Case non cochée
- [x] Case cochée
```

---

## Titres

Les titres sont créés avec un certain nombre de # avant le titre, qui correspondent au niveau de titre souhaité

# un titre de premier niveau
#### un titre de quatrième niveau

```
# un titre de premier niveau
#### un titre de quatrième niveau
```

---

Pour les deux premiers niveaux de titre, il est également possible de souligner le titre avec des = ou des - (leur nombre réel importe peu, mais il doit être supérieur à 2).

Titre de niveau 1
=====================

Titre de niveau 2
-------------------

```
Titre de niveau 1
=====================

Titre de niveau 2
-------------------
```

---

## Tableaux

Pour créer des tableaux

| Titre 1       |     Titre 2     |   Titre 3      |
| ------------- | -------------   | ---------      |
| Colonne       |     Colonne     |      Colonne   |
| Alignée à     |      Alignée au |     Alignée à  |
| Gauche        |      Centre     |      Droite    |

```
| Titre 1       |     Titre 2     |   Titre 3      |
| ------------- | -------------   | ---------      |
| Colonne       |     Colonne     |      Colonne   |
| Alignée à     |      Alignée au |     Alignée à  |
| Gauche        |      Centre     |      Droite    |
```

---

## Liens

Pour créer des liens

[texte du lien](url_du_lien "texte pour le titre, facultatif")

```
[texte du lien](url_du_lien "texte pour le titre, facultatif")
```

---

## Images

Pour afficher une image

![Texte alternatif](url_de_l'image "texte pour le titre, facultatif")

```
![Texte alternatif](url_de_l'image "texte pour le titre, facultatif")
```

---

[Article source](https://fr.wikipedia.org/wiki/Markdown "Sur le site de Wikipédia")