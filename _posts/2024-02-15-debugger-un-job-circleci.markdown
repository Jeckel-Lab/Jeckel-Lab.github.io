---
layout: post
title: Comment debugger un Job dans CircleCI
tags: [ci-cd, page-ci]
category: ci-cd
has_code: true
description: "Explorez les meilleures pratiques pour l'intégration et le déploiement continus avec CircleCI. Découvrez comment configurer efficacement vos workflows, déboguer en local et via SSH, et optimiser vos pipelines CI/CD pour une automatisation sans faille. Que vous soyez débutant ou avancé, ce guide vous offre des conseils précieux, des tutoriels CircleCI, et des astuces pour améliorer la sécurité, la performance et l'efficacité de vos projets. Maîtrisez CircleCI avec des solutions innovantes pour GitHub, Bitbucket et GitLab."
keywords: "CircleCI, Intégration continue, Déploiement continu, CI/CD, Configuration CircleCI, CircleCI GitHub, CircleCI Bitbucket, CircleCI GitLab, Automatisation CircleCI, Tutoriel CircleCI, CircleCI CLI, Debugging CircleCI, CircleCI SSH, Pipeline CI/CD, CircleCI Jobs, Workflow automation, DevOps CircleCI, CircleCI YAML, API Token CircleCI, CircleCI local execution, Tests automatisés CircleCI, CircleCI Docker, Optimisation CircleCI, Sécurité CircleCI, Performance CI/CD, CircleCI environnement local, Débogage CircleCI, CircleCI et cloud, Intégration GitHub CircleCI, CircleCI pour débutants, CircleCI avancé, Best practices CircleCI, CircleCI API, CircleCI et SSH, CircleCI configuration tips, CircleCI setup guide, CircleCI et tests, CircleCI et permissions, CircleCI et réseau, CircleCI build errors, CircleCI custom jobs, CircleCI et déploiement, CircleCI et Docker, CircleCI et sécurité, CircleCI et performances, CircleCI plugins, CircleCI et intégration, CircleCI et volumétrie, CircleCI et qualité de code, CircleCI pour les entreprises"
complexity: 2
---
[CircleCI](https://circleci.com/) est un outil très complet pour créer des workflows d'intégration continue et de déploiement continu. C'est un outil très polyvalent qui a, en plus, l'avantage de ne pas être dépendant de votre répertoire de code. En effet, on peut l'utiliser aussi bien avec [Github](https://github.com/), [Bitbucket](https://bitbucket.org/) ou encore [GitLab](https://about.gitlab.com/).

En revanche, même si tout fonctionne très bien localement, lorsque l'on déploie les opérations d'intégration continue sur CircleCI, il arrive très souvent (surtout au début) que l'on rencontre des difficultés de configuration ou des problèmes de permissions spécifiques à l'environnement d'exécution.

Je vais donc vous présenter ici deux solutions qui peuvent vous aider à vous en sortir rapidement.

## Exécuter CircleCI localement

CircleCI propose un client permettant d'exécuter ses jobs localement. Cet outil permet de lancer manuellement et localement les jobs presque comme s'ils s'exécutaient directement dans l'environnement distant.

Je dis bien presque, parce qu'il va y avoir quelques différences liées au réseau et à la configuration de votre machine, mais dans la majorité des cas, ces différences seront transparentes.

### Installation et configuration

La première étape consiste, évidemment, à installer ce client. Je vous invite donc à consulter la [documentation d'installation propre à votre système](https://circleci.com/docs/local-cli/).

Ensuite, vous allez devoir le configurer pour lui permettre d'accéder à votre environnement CircleCI, à vos paramètres et à vos permissions.

Il vous faut tout d'abord générer un **Personal API Token** [directement sur le site](https://app.circleci.com/settings/user/tokens).

Une fois ce token récupéré, configurez CircleCI-Cli :
```bash
$> circleci setup
```
Et donc, lui donner le token quand il vous le demande.

### Exécution d'un job sur la machine locale

Une fois la configuration terminée, vous pourrez lancer les jobs que vous souhaitez en vous rendant dans votre projet :
```bash
$> circleci local execute <JOB_NAME>
```
Avec <JOB_NAME> le nom d'un job défini dans votre fichier `.circleci/config.yml`

Dans la majorité des cas, cela vous permettra de tester votre configuration CircleCI sans avoir à pousser votre configuration à chaque changement et attendre de voir ce qui se passe sur l'interface web.

## Debugger directement sur CircleCI via une connection ssh

**CircleCI** propose une autre solution pour déboguer les jobs récalcitrants. En effet, il est possible de relancer un job en échec en ouvrant une connexion SSH qui vous permet de vous connecter directement à l'instance où s'exécute le job et de le déboguer en temps réel.

Pour celà, rendez-vous sur la page du job en erreur, puis en haut à droite, déplier le menu sous "Rerun", et vous verrez l'option "Rerun job with SSH"

![CircleCi - ReRun Job with Ssh](/images/CircleCi-RerunJobWithSsh.png){: .center-image}

Cette action va relancer le job en question en ouvrant une connexion SSH sur l'environnement d'exécution du job.

- Cette connection n'est disponible que pendant 1h.
- Pour se connecter, vous aurez besoin d'une clé SSH, en général, il s'agit de celle utilisée par Git sur votre répertoire (CircleCI aura récupéré la clé publique).

Dans le log de nouveau Job vous verrez un bloc supplémentaire "Enable SSH" à l'intérieur duquel vous trouverez les informations nécessaires à vous connecter.

![CircleCi - Connection au job via Ssh](/images/CircleCi-ConnectToJobWithSsh.png){: .center-image}

Il vous suffit alors de vous connecter depuis votre terminal via SSH en précisant votre clé (si ce n'est pas votre clé par défaut), par exemple :
```bash
$> ssh -p 64535 -i .ssh/keys/id_ed25519 3.91.14.100
```

Vous serez ainsi connecté directement à la machine sur laquelle le job est en cours d'exécution. Vous pourrez donc y effectuer tous les tests en temps réel pour identifier ce qui bloque votre build : fichier manquant, problème de permission, connexion réseau, etc.

## Conclusion

Voici deux méthodes différentes répondant toutes deux à des cas d'usage différents qui pourront vous aider à déboguer et à faire évoluer vos pipelines d'intégration continue et de déploiement continu avec CircleCI.
