import 'package:avesso_x_go/core/utils/formatters.dart';

class DemoEvent {
  const DemoEvent({
    required this.id,
    required this.title,
    required this.location,
    required this.date,
    required this.description,
    required this.price,
    required this.category,
  });

  final String id;
  final String title;
  final String location;
  final DateTime date;
  final String description;
  final double price;
  final String category;

  String get formattedDate => Formatters.formatDateBR(date);
  String get formattedPrice => Formatters.formatBRL(price);

  /// Serializa o evento para armazenamento local via `shared_preferences`.
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'location': location,
        'date': date.toIso8601String(),
        'description': description,
        'price': price,
        'category': category,
      };

  /// Reconstrói um evento a partir da representação persistida.
  factory DemoEvent.fromJson(Map<String, dynamic> json) => DemoEvent(
        id: json['id'] as String,
        title: json['title'] as String,
        location: json['location'] as String,
        date: DateTime.parse(json['date'] as String),
        description: json['description'] as String,
        price: (json['price'] as num).toDouble(),
        category: json['category'] as String,
      );
}

final List<DemoEvent> demoEvents = [
  DemoEvent(
    id: 'sunset-festival',
    title: 'Sunset Festival',
    location: 'Arena Venn, São Paulo',
    date: DateTime(2026, 9, 12),
    description:
        'Um festival de música eletrônica ao ar livre com as melhores atrações '
        'nacionais e internacionais. Estrutura completa, áreas de descanso, '
        'gastronomia variada e uma experiência inesquecível do pôr do sol '
        'até o amanhecer.',
    price: 199.9,
    category: 'Festival',
  ),
  DemoEvent(
    id: 'coding-summit',
    title: 'Coding Summit 2026',
    location: 'Expo Center Norte, São Paulo',
    date: DateTime(2026, 10, 3),
    description:
        'O maior encontro de tecnologia e desenvolvimento do ano. Palestras, '
        'workshops práticos, hackathon e networking com referências do mercado.',
    price: 89.9,
    category: 'Tecnologia',
  ),
  DemoEvent(
    id: 'jazz-night',
    title: 'Jazz & Vinho Night',
    location: 'Teatro B32, Belo Horizonte',
    date: DateTime(2026, 9, 20),
    description:
        'Uma noite sofisticada com apresentações de jazz ao vivo, seleção de '
        'vinhos premium e gastronomia autoral em um ambiente intimista.',
    price: 120,
    category: 'Show',
  ),
  DemoEvent(
    id: 'city-run',
    title: 'City Run 10K',
    location: 'Parque Ibirapuera, São Paulo',
    date: DateTime(2026, 11, 8),
    description:
        'Corrida urbana com percurso de 10km pelos pontos turísticos da '
        'cidade. Kits com camiseta exclusiva, medalha de participação e '
        'cronometragem oficial.',
    price: 45,
    category: 'Esporte',
  ),
  DemoEvent(
    id: 'synth-live',
    title: 'Synth Live Sessions',
    location: 'Audio Club, Recife',
    date: DateTime(2026, 10, 17),
    description:
        'Performances audiovisuais imersivas com artistas do cenário '
        'experimental brasileiro. Uma jornada sonora única em um clube '
        'histórico da cidade.',
    price: 75.5,
    category: 'Show',
  ),
  DemoEvent(
    id: 'future-tech-expo',
    title: 'Future Tech Expo',
    location: 'Centro de Convenções, Rio de Janeiro',
    date: DateTime(2026, 12, 5),
    description:
        'Feira de inovação com demonstrações de IA, robótica e realidade '
        'virtual. Ideal para curiosos, estudantes e profissionais de tecnologia.',
    price: 259.9,
    category: 'Tecnologia',
  ),
];

DemoEvent? demoEventById(String id) {
  for (final event in demoEvents) {
    if (event.id == id) {
      return event;
    }
  }
  return null;
}