# MedicaTime

Um aplicativo Flutter para gerenciamento de medicações e lembretes.

## Funcionalidades

- **Autenticação**: Login e registro de usuários com Firebase Auth.
- **Perfil**: Editar nome do usuário.
- **Medicações**: Adicionar, editar e excluir medicações com dosagem, horários diários ou semanais, e notas.
- **Notificações**: Notificações locais para lembretes de medicações com ações para marcar como tomado ou ignorado.
- **Histórico**: Registrar e visualizar histórico de medicações tomadas, ignoradas ou perdidas, com percentual de adesão e gráfico semanal.

## Configuração

1. Configure um projeto no Firebase Console.
2. Ative Authentication (Email/Password) e Firestore.
3. Baixe os arquivos de configuração `google-services.json` (Android) e `GoogleService-Info.plist` (iOS) e coloque nos diretórios apropriados.
4. Execute `flutter pub get` para instalar dependências.

## Como executar

```bash
flutter run
```

## Estrutura do Projeto

- `lib/main.dart`: Ponto de entrada da aplicação.
- `lib/providers/`: Providers para gerenciamento de estado (Auth e Medication).
- `lib/screens/`: Telas da aplicação.
- `lib/models/`: Modelos de dados (Medication e MedicationHistory).
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
