# PicToText - Tutorial de desenvolvimento

> Todos os passos descritos neste tutorial, e a sua elaboração,  foram feitos por Victor Hugo M. Pinto.

Neste tutorial, vamos aprender como desenvolver um aplicativo para iOS capaz de reconhecer texto em imagens. As principais funcionalidades desse aplicativo, que vamos focar no tutorial são as seguintes:

- Uso de Flutter, que permite facilmente o desenvolvimento do mesmo aplicativo em versões para Android ou até para a Web. Apesar deste tutorial focar em específico na criação do app para iOS, você vai ver que o processo para desenvolver a mesma aplicação pensando no Android é basicamente o mesmo.
- Armazenamento de dados na nuvem, por meio do módulo *Firestore*, também do Google Firebase. Aliado à funcionalidade de login, esse armazenamento em nuvem nos permite separar os dados salvos *por usuário*.
- Reconhecimento de texto em imagens utilizando o ML Kit, solução da Google para aprendizado de máquina **local**, ou seja, no dispositivo.
- Login com o Google, por meio do módulo de autenticação do Google Firebase.

As imagens abaixo mostram o estado final do app rodando em um iPhone.

<div style="display: 'flex'">
  <img src="./img/login.png" width="24%" />
	<img src="./img/home.png" width="24%" />
  <img src="./img/drawer_open.png" width="24%" />
  <img src="./img/action_open.png" width="24%" />
</div>

## Setup e ferramentas

Esta é a sessão menos divertida de qualquer tutorial, mas precisamos garantir que temos um setup funcionando bem para facilitar nosso fluxo de desenvolvimento.

As instruções abaixo são baseadas no setup em um computador rodando macOS, até por este ser um pré-requisito para o desenvolvimento de apps para iOS. Apesar disso, em computadores com Windows ou Linux, o setup não é muito diferente, e é muito bem descrito na documentação oficial das ferramentas.

### Flutter + Xcode

Vamos começar com o [**Flutter**](https://flutter.dev/), um *toolkit* criado e mantido pela Google que nos permite o desenvolvimento de aplicações para dispositivos móveis (iOS e Android), para a Web ou para *desktop*s utilizando a mesma base de código. Um grande diferencial do Flutter para outras soluções de desenvolvimento *mobile* para múltiplas plataformas é que aplicações criadas com Flutter são compiladas para código nativo, e sua performance não é negativamente impactada por *runtimes* ou *web views* sendo utilizadas para renderizar o app. Apps criados com Flutter são indiscerníveis de apps criados com Swift (iOS) ou Kotlin/Java (Android).

As instruções completas para instalação em qualquer SO podem ser encontradas em: [Install - Flutter](https://flutter.dev/docs/get-started/install ). Vou descrever rapidamente cada um dos passos, com algumas recomendações.

1. Baixar o Flutter SDK, disponível na página de instalação. É importante usar o link direto da página oficial para evitar problemas. Não recomendo usar a alternativa descrita, que envolve clonar o repositório do GitHub e utilizar a versão estável direto de lá. Note que o arquivo baixado é um `.zip`.

2. Descomprima o arquivo `.zip` na localização onde pretende deixá-lo. No macOS, basta clicar duas vezes no arquivo e será criada uma pasta de mesmo nome ao lado do `.zip`. Essa pasta resultante contém tudo o que o Flutter precisa para funcionar, inclusive seu binário.

3. Vamos adicionar o Flutter ao `PATH` do seu *shell*, para facilitar o desenvolvimento. Este passo pode variar ligeiramente dependendo do *shell* que você usa. Nas versões mais recentes do macOS, o *shell* padrão é o *zsh*. Nesse caso, basta adicionar a seguinte linha ao arquivo `$HOME/.zshrc`:

   ```shell
   export PATH="$PATH:[CAMINHO PARA A PASTA FLUTTER CRIADA NO PASSO ANTERIOR]/flutter/bin"
   ```

   Se estiver usando `bash`, a mesma linha deve funcionar, porém ela deve ser adiciona ao arquivo `$HOME/.bash_profile` ou `$HOME/.bashrc`.

   Para atualizar sua sessão atual do shell, execute:

   ```shell
   $ source $HOME/.<arquivo_de_configuração_modificado>
   ```

   Agora basta verificar se `flutter/bin` de fato está no seu PATH:

   ```shell
   $ echo $PATH
   ```

   E podemos verificar que o comando `flutter` está funcionando executando:

   ``` shell
   $ which flutter
   ```

Agora já conseguimos executar comandos do Flutter! Vamos agora fazer o setup do Xcode para podermos desenvolver para o iOS. Não vou comentar sobre o setup para desenvolvimento para Android, mas ele está na [mesma página da documentação do Flutter](https://flutter.dev/docs/get-started/install/macos#android-setup), e é tão simples quanto o do iOS, podendo ser feito em **qualquer** SO.

1. Primeiro precisamos instalar o Xcode. Isso pode ser feito pela [Mac App Store](https://apps.apple.com/br/app/xcode/id497799835?l=en&mt=12). O download é bem grande, cerca de 11Gb, então pode demorar dependendo da sua internet.

2. Uma vez que o Xcode está instalado, vamos configurar o *Xcode command-line tools* para utilizar a versão do Xcode que acabou de ser instalada:

   ```shell
   $ sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
   $ sudo xcodebuild -runFirstLaunch
   ```

3. Agora, com o Xcode instalado, temos tudo o que precisamos para desenvolver para iOS! Você pode verificar que tudo está correto com o comando:

   ```shell
   $ flutter doctor
   ```

   Também já podemos deixar um simulador de iOS aberto, ele será muito útil durante o desenvolvimento:

   ```shell
   $ open -a Simulator
   ```

### VSCode

Esta parte do tutorial é totalmente opcional, mas recomendo o uso do VSCode para desenvolvimento. Mais informações sobre ele podem ser encontradas no [site oficial](https://code.visualstudio.com/), e seu download também.

O time do Fluter criou plugins do VSCode excelentes para ajudar com o desenvolvimento. Para instalá-los:

1. Abra o VSCode
2. Abra a *command palette* pelo atalho `cmd + shift + p` ou pela barra de menu, em **View > Command Palette...**.
3. Comece a digitar "install" e selecione a opção **Extensions: Install Extensions**.
4. Digite "flutter" e instale a extensão **Flutter** na lista. Isso vai instalar também uma extensão para a linguagem **Dart**, utilizada no desenvolvimento com Flutter.

### Validando o setup de desenvolvimento

Agora que fizemos todo o setup local de desenvolvimento, vamos rapidamente testá-lo para garantir que não vamos ter problemas durante os próximos passos. Vamos criar o nosso projeto Flutter e executá-lo no simulador iOS pela primeira vez!

1. Vá até o diretório em que pretende desenvolver o app, e execute o seguinte comando para criar um novo projeto Flutter:

   ```shell
   $ flutter create pic_to_text
   ```

   Este comando vai criar um novo diretório chamado `pic_to_text`, com um projeto Flutter já funcional dentro.

2. Navegue até o diretório criado e execute o projeto, com o comando:

   ```shell
   $ flutter run
   ```

   Este comando faz o *build* do projeto, e o executa em um dispositivo compatível conectado ao computador, no nosso caso o próprio simulador.

### Firebase

O próximo passo é configurar o Firebase, que vamos utilizar para cuidar da autenticação e do armazenamento de dados da nossa aplicação.

Não precisamos fazer o setup completo agora, mas vamos pelo menos fazer o primeiro login e criar um novo projeto no Firebase.

1. Acesse https://firebase.google.com/.
2. Faça login com a sua conta do Google
3. Você deverá ter sido levado para o *console*. Aqui é onde você pode ver todos os seus projetos que utilizam o Firebase.
4. Clique em "Adicionar projeto"
5. Dê um nome para o projeto, no caso do tutorial, "PicToText"
6. Recomendo não ativar o Analytics pois não vamos utilizá-lo.

Pronto! Agora já temos um projeto criado no Firebase! Vamos voltar a usar e modificar este projeto ao longo do desenvolvimento do projeto conforme adicionamos novas funcionalidades no app.

## Interagindo com a câmera e a galeria de imagens do dispositivo

## Reconhecendo texto

## Login com Google

## Armazenando dados na nuvem

## Próximos passos

