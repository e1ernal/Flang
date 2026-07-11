# Flang

**Traga de volta as bandeiras dos países no seletor de fontes de entrada do macOS.**

[English](../../README.md) | [Español](README.es.md) | [Français](README.fr.md) | Português | [中文](README.zh-Hans.md) | [日本語](README.ja.md) | [Русский](README.ru.md)

Até o macOS 12.4, o seletor de layout de teclado na barra de menus mostrava a
bandeira de um país. A Apple então substituiu as bandeiras por rótulos de
texto ("ABC", "ES"). O Flang é um pequeno app de barra de menus que traz as
bandeiras de volta — e permite que você decida qual bandeira, e qual nome,
representa cada um dos seus idiomas.

<!-- TODO: captura de tela / GIF do seletor na barra de menus -->

## Recursos

| | |
|---|---|
| Bandeira na barra de menus | Fonte de entrada atual mostrada com sua bandeira, atualizada instantaneamente |
| Troca familiar | Clique para ver todas as suas fontes de entrada e alternar, assim como o menu do sistema |
| Indicador flexível | Bandeira e nome exibidos de forma independente — um, ambos ou nenhum (recorre ao ícone do sistema) |
| Dois estilos de bandeira | Imagens de bandeira planas (o visual clássico) ou emojis de bandeira nativos |
| Padrões sensatos | Cada layout de teclado e método de entrada do macOS recebe uma bandeira padrão razoável |
| Personalização completa | Qualquer bandeira, nome curto e nome completo personalizados para cada idioma |
| Impacto mínimo | Sem coleta de dados, inicia com o login, poucos megabytes; a única chamada de rede é uma verificação diária opcional de atualizações |

Idiomas não estão ligados a países — é exatamente por isso que o Flang torna
a bandeira uma escolha pessoal. Prefere a bandeira do Canadá para o francês,
ou a do México para o espanhol? Dois cliques.

## Instalação

Baixe o zip mais recente no
[GitHub Releases](https://github.com/e1ernal/Flang/releases), descompacte-o e
mova o Flang.app para Aplicativos — depois veja abaixo antes de abri-lo.

Para compilar a partir do código-fonte:

```bash
git clone https://github.com/e1ernal/Flang.git
open Flang/Flang.xcodeproj
```

Compile e execute com Cmd+R (Xcode 16 ou mais recente, macOS 13 Ventura ou mais recente).

### Abrindo um app não assinado

O Flang não é notarizado pela Apple. A notarização exige uma assinatura paga
do Apple Developer Program, que este projeto ainda não tem — o plano é
providenciar isso depois que a 1.0 provar que existe um público que valha a
pena (veja o [roadmap](#roadmap)). Até lá, o Gatekeeper do macOS bloqueia um
clique duplo comum com "O Flang não pode ser aberto porque a Apple não
consegue verificar se ele contém malware."

Isso é esperado, não é um bug nem sinal de que algo está errado. Para abrir
pela primeira vez:

1. Clique com o botão direito (ou Control-clique) em Flang.app em Aplicativos e escolha **Abrir**.
2. Clique em **Abrir** novamente na caixa de diálogo que aparecer.

<!-- TODO(docs/images/gatekeeper-open.png): captura de tela do menu de
contexto "Abrir" do botão direito em Flang.app, ou da caixa de diálogo do Gatekeeper -->

Você só precisa fazer isso uma vez — todo lançamento depois disso, incluindo
futuras atualizações, abre normalmente.

## Uso

1. Abra o Flang — uma bandeira aparece na sua barra de menus.
2. Clique nela para trocar de fonte de entrada; clique com o botão direito para Ajustes e Sair.
3. Opcional: oculte o seletor nativo do sistema em
   Ajustes do Sistema — Teclado — desmarque "Mostrar o menu de entrada na
   barra de menus". O macOS não permite que apps façam isso
   automaticamente, então é um passo manual único.

   <img src="../images/hide-system-switcher.png" width="500" alt="Ajustes do Sistema — Teclado, com &quot;Mostrar o menu de entrada na barra de menus&quot; destacado">

4. Para adicionar ou remover um layout de teclado, abra Ajustes — Fontes de
   Entrada e use o botão "+" (ou Excluir em uma fonte) — ambos direcionam
   para Ajustes do Sistema — Teclado — Fontes de Entrada, onde o macOS lida
   com isso diretamente.

   <img src="../images/add-input-source.png" width="500" alt="A aba Fontes de Entrada do Flang, com o botão &quot;+&quot; destacado">

## Perguntas frequentes

**O Flang substitui o seletor do sistema?**
Funcionalmente sim: ele lista e alterna as mesmas fontes de entrada usando as
mesmas APIs do sistema. O indicador próprio do sistema só pode ser ocultado
manualmente (veja Uso).

**O Flang precisa de internet?**
Não. A única chamada de rede opcional é uma verificação diária de novas
versões no GitHub. Nada sobre você ou seu sistema é enviado a lugar nenhum.

## Roadmap

- [x] Indicador na barra de menus com a bandeira da fonte de entrada ativa
- [x] Trocar fontes de entrada pelo menu suspenso
- [x] Mapa de bandeiras padrão para todos os layouts e métodos de entrada do macOS
- [x] Modos de bandeira em imagem e emoji
- [x] Configurações independentes de bandeira e nome, com pré-visualização ao vivo
- [x] Janela de ajustes: bandeira, nome curto e nome completo personalizados por idioma
- [x] Iniciar com o login, dicas no primeiro lançamento
- [x] Verificação de atualizações via GitHub Releases
- [x] Interface localizada em EN e RU
- [x] Builds zip distribuíveis via GitHub Releases
- [x] README localizado (ES, FR, JA, PT-BR, ZH-Hans, RU)
- [ ] Builds assinados e atualizações automáticas

## Contribuindo

Issues e pull requests são bem-vindos.

## Créditos e licença

| | |
|---|---|
| Imagens de bandeiras | [flag-icons](https://github.com/lipis/flag-icons) por lipis, Licença MIT |
| Flang | Distribuído sob a [Licença MIT](../../LICENSE) |
