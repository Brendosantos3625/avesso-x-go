# avesso_x_go

**AVESSO X GO** — aplicativo Flutter de eventos e ingressos.

## Estrutura

- `lib/` — aplicação organizada em camadas
  (`Presentation → Controller → Repository → Data Source`).
- `test/` — testes automatizados (unitários e de widgets).
- `supabase/` — migrations e configuração do backend Supabase.
- `docs/` — documentação técnica.

## Documentação

- `docs/backend-migration.md` — plano e status da migração para o Supabase.
- `supabase/README.md` — como aplicar as migrations e configurar o backend.

## Rodando (modo local)

Sem configuração extra, o app roda 100% local (demonstração), com conta demo
`demo@avesso.com` / `avesso123`.

Com Supabase configurado:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=<anon-key>
```

Ou via arquivo:

```bash
cp .env.example .env   # preencha os valores
flutter run --dart-define-from-file=.env
```

## Testes e verificação

```bash
flutter pub get
flutter analyze
flutter test
flutter build web --release
```