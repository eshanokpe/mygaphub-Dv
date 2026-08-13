class UnbordingContent {
  String image;
  String title;
  String discription;

  UnbordingContent({
    required this.image,
    required this.title,
    required this.discription,
  });
}

List<UnbordingContent> contents = [
  UnbordingContent(
    title: 'Calculate',
    image: 'assets/images/splashscreen/Calculate.svg',
    discription:
        "Calculate your financial independence and establish achievable goals to reach this milestone ",
  ),
  UnbordingContent(
    title: 'Analytics',
    image: 'assets/images/splashscreen/Analytics.svg',
    discription:
        "Experience the transformative power of visualization to achieve your goals and dreams ",
  ),
  UnbordingContent(
    title: 'Budgeting',
    image: 'assets/images/splashscreen/Budgeting.svg',
    discription:
        "Deploy budgeting to smartly manage your spending and re-channel your money intelligently",
  ),
  UnbordingContent(
    title: 'Acquisition',
    image: 'assets/images/splashscreen/Acquisition.svg',
    discription:
        "Gain access to great asset acquisition opportunities globally across multiple asset classes",
  ),
  UnbordingContent(
    title: 'Portfolio',
    image: 'assets/images/splashscreen/Portfolio.svg',
    discription:
        "Onboard your existing assets and manage your portfolio most efficiently leveraging on data science",
  ),
  UnbordingContent(
    title: 'Connectedness',
    image: 'assets/images/splashscreen/Connectedness.svg',
    discription:
        "Connect all the areas of your financial life and control them at the tip of your finger",
  ),
];
