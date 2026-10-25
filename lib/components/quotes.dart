import 'dart:math';

/// Motivational and breathing-health quotes shown on the patient dashboard.
///
/// A fresh one is picked at every patient sign-in by [startPatientSession]
/// and stays stable for the rest of that session — re-entering the dashboard
/// (e.g. after the spigotting sheet) shows the same quote until the next login.
class Quote {
  const Quote(this.text, this.author);

  final String text;
  final String author;
}

const List<Quote> motivationalQuotes = [
  Quote('Every breath you take is proof of your strength.', 'TrachCare'),
  Quote('Healing is not a race. Rest, breathe, and keep going.', 'TrachCare'),
  Quote('Small steps every day become big recoveries.', 'TrachCare'),
  Quote('Your body is working hard to heal — be patient with it.', 'TrachCare'),
  Quote('One clear breath at a time. You are doing great.', 'TrachCare'),
  Quote('Courage is taking the next breath even when it feels hard.', 'TrachCare'),
  Quote('Recovery grows in quiet moments of care and consistency.', 'TrachCare'),
  Quote('You are stronger than today’s challenge.', 'TrachCare'),
  Quote('Each day of care is a day closer to breathing easy.', 'TrachCare'),
  Quote('Breathe in hope, breathe out worry.', 'TrachCare'),
  Quote('Your care routine today is your strength tomorrow.', 'TrachCare'),
  Quote('Progress, not perfection — every report you file matters.', 'TrachCare'),
  Quote('The tube helps you breathe; your spirit helps you heal.', 'TrachCare'),
  Quote('Take it slow. Your lungs are learning to be free again.', 'TrachCare'),
  Quote('A calm mind and a clear airway make healing faster.', 'TrachCare'),
  Quote('Today’s effort is tomorrow’s easy breath.', 'TrachCare'),
  Quote('You are not alone — your care team is one tap away.', 'TrachCare'),
  Quote('Consistency in small things builds great health.', 'TrachCare'),
];

final _random = Random();

/// Picks a quote at random; pass a seeded [rnd] in tests for determinism.
Quote randomQuote([Random? rnd]) =>
    motivationalQuotes[(rnd ?? _random).nextInt(motivationalQuotes.length)];

/// The quote for the current patient session — refreshed on every login.
Quote? sessionQuote;

/// Call at the start of each patient session (after sign-in/sign-up) so the
/// dashboard's "Thought for today" card shows a new quote every login.
void startPatientSession([Random? rnd]) {
  sessionQuote = randomQuote(rnd);
}
