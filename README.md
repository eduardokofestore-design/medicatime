# MedicaTime

Um aplicativo Flutter para gerenciamento de medicamentos com sistema de autenticação.

## Funcionalidades

- Criação de conta de usuário
- Login e logout
- Edição de perfil com foto e nome
- Homepage personalizada

## Configuração do Firebase

Para o aplicativo funcionar, você precisa configurar o Firebase:

1. Crie um projeto no [Firebase Console](https://console.firebase.google.com/).
2. Adicione um app Android:
   - Package name: com.example.medicatime (ou o que estiver no android/app/build.gradle)
   - Baixe o google-services.json e coloque em `android/app/`
3. Adicione um app iOS:
   - Bundle ID: com.example.medicatime
   - Baixe o GoogleService-Info.plist e coloque em `ios/Runner/`
4. No Firebase Console:
   - Ative Authentication com Email/Password
   - Ative Firestore Database
   - Ative Storage

## Executando o App

1. Instale as dependências: `flutter pub get`
2. Execute o app: `flutter run`

## Dependências

- firebase_core
- firebase_auth
- cloud_firestore
- firebase_storage
- provider
- image_picker
