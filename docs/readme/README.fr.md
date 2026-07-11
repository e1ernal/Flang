# Flang

**Ramène les drapeaux des pays dans le sélecteur de source de saisie de macOS.**

[English](../../README.md) | [Español](README.es.md) | Français | [Português](README.pt-BR.md) | [中文](README.zh-Hans.md) | [日本語](README.ja.md)

Jusqu'à macOS 12.4, le sélecteur de disposition de clavier dans la barre de
menus affichait le drapeau d'un pays. Apple a ensuite remplacé les drapeaux
par des libellés texte ("ABC", "ES"). Flang est une petite application de
barre de menus qui ramène les drapeaux — et vous laisse choisir quel drapeau,
et quel nom, représente chacune de vos langues.

<!-- TODO : capture d'écran / GIF du sélecteur dans la barre de menus -->

## Fonctionnalités

| | |
|---|---|
| Drapeau dans la barre de menus | La source de saisie active affichée avec son drapeau, mis à jour instantanément |
| Changement familier | Cliquez pour voir toutes vos sources de saisie et en changer, comme le menu système |
| Indicateur flexible | Drapeau et nom affichés indépendamment — l'un, les deux, ou aucun (repli sur l'icône système) |
| Deux styles de drapeau | Images de drapeau plates (le look classique) ou emojis de drapeau natifs |
| Valeurs par défaut sensées | Chaque disposition de clavier et méthode de saisie macOS reçoit un drapeau par défaut raisonnable |
| Personnalisation complète | N'importe quel drapeau, nom court et nom complet personnalisés pour chaque langue |
| Empreinte minimale | Aucune collecte de données, démarre à la connexion, quelques mégaoctets ; le seul appel réseau est une vérification quotidienne optionnelle des mises à jour |

Les langues ne sont pas liées à des pays — c'est exactement pour cela que
Flang fait du drapeau un choix personnel. Vous préférez le drapeau canadien
pour le français, ou le drapeau mexicain pour l'espagnol ? Deux clics.

## Installation

Téléchargez le dernier DMG depuis les
[GitHub Releases](https://github.com/e1ernal/Flang/releases), ouvrez-le, et
glissez Flang.app dans Applications — puis lisez la suite avant de l'ouvrir.

Pour compiler depuis les sources à la place :

```bash
git clone https://github.com/e1ernal/Flang.git
open Flang/Flang.xcodeproj
```

Compilez et lancez avec Cmd+R (Xcode 16 ou plus récent, macOS 13 Ventura ou plus récent).

### Ouvrir une application non signée

Flang n'est pas notariée par Apple. La notarisation nécessite un abonnement
payant à l'Apple Developer Program, que ce projet n'a pas encore — c'est
prévu une fois que la 1.0 aura prouvé qu'il existe un public prêt à
justifier la dépense (voir la [feuille de route](#feuille-de-route)).
D'ici là, le Gatekeeper de macOS bloque un simple double-clic avec « Flang
ne peut pas être ouvert car Apple ne peut pas vérifier qu'il ne contient pas
de logiciel malveillant. »

C'est normal, ce n'est ni un bug ni un signe que quelque chose ne va pas.
Pour l'ouvrir la première fois :

1. Faites un clic droit (ou Ctrl-clic) sur Flang.app dans Applications et choisissez **Ouvrir**.
2. Cliquez à nouveau sur **Ouvrir** dans la boîte de dialogue qui apparaît.

<!-- TODO(docs/images/gatekeeper-open.png) : capture du menu contextuel clic
droit "Ouvrir" sur Flang.app, ou de la boîte de dialogue Gatekeeper -->

Cette étape n'est nécessaire qu'une seule fois — chaque lancement suivant, y
compris les futures mises à jour, s'ouvre normalement.

## Utilisation

1. Lancez Flang — un drapeau apparaît dans votre barre de menus.
2. Cliquez dessus pour changer de source de saisie ; clic droit pour Réglages et Quitter.
3. Optionnel : masquez le sélecteur système intégré dans
   Réglages Système — Clavier — décochez « Afficher le menu de saisie dans la
   barre de menus ». macOS ne permet pas aux applications de le faire
   automatiquement, c'est donc une étape manuelle unique.

   <img src="../images/hide-system-switcher.png" width="500" alt="Réglages Système — Clavier, avec « Afficher le menu de saisie dans la barre de menus » mis en évidence">

4. Pour ajouter ou retirer une disposition de clavier, ouvrez Réglages —
   Sources de saisie et utilisez le bouton « + » (ou Supprimer sur une
   source) — les deux renvoient vers Réglages Système — Clavier — Sources de
   saisie, où macOS s'en charge directement.

   <img src="../images/add-input-source.png" width="500" alt="L'onglet Sources de saisie de Flang, avec le bouton « + » mis en évidence">

## FAQ

**Flang remplace-t-il le sélecteur système ?**
Fonctionnellement oui : il liste et change les mêmes sources de saisie via
les mêmes API système. L'indicateur du système lui-même ne peut être masqué
que manuellement (voir Utilisation).

**Flang a-t-il besoin d'internet ?**
Non. Le seul appel réseau optionnel est une vérification quotidienne des
nouvelles versions sur GitHub. Rien concernant vous ou votre système n'est
jamais envoyé où que ce soit.

## Feuille de route

- [x] Indicateur de barre de menus avec un drapeau pour la source de saisie active
- [x] Changer de source de saisie depuis le menu déroulant
- [x] Carte de drapeaux par défaut pour toutes les dispositions et méthodes de saisie macOS
- [x] Modes drapeau image et emoji
- [x] Réglages d'affichage indépendants pour drapeau et nom, avec aperçu en direct
- [x] Fenêtre de réglages : drapeau, nom court et nom complet personnalisés par langue
- [x] Démarrage à la connexion, astuces au premier lancement
- [x] Vérification des mises à jour via GitHub Releases
- [x] Interface localisée en EN et RU
- [x] Compilations DMG distribuables via GitHub Releases
- [x] README localisé (ES, FR, JA, PT-BR, ZH-Hans)
- [ ] Compilations signées et mises à jour automatiques

## Contribuer

Les issues et pull requests sont les bienvenus.

## Crédits et licence

| | |
|---|---|
| Images de drapeaux | [flag-icons](https://github.com/lipis/flag-icons) par lipis, Licence MIT |
| Flang | Distribué sous [Licence MIT](../../LICENSE) |
