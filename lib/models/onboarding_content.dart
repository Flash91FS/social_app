class OnbordingContent {
  String image;
  String title;
  String discription;

  OnbordingContent({required this.image, required this.title, required this.discription});
}

List<OnbordingContent> contents = [
  OnbordingContent(
      title: 'Browse Spots',
      image: 'assets/images/onboarding_browse.png',
      discription: "simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the "
          "industry's standard dummy text ever since the 1500s, "
          "when an unknown printer took a galley of type and scrambled it "
  ),
  OnbordingContent(
      title: 'Post Your Spots',
      image: 'assets/images/onboarding_posting.png',
      // image: 'assets/ic_instagram.svg',
      discription: "simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the "
          "industry's standard dummy text ever since the 1500s, "
          "when an unknown printer took a galley of type and scrambled it "
  ),
  OnbordingContent(
      title: 'Share Your Spots',
      image: 'assets/images/onboarding_share.png',
      // image: 'assets/ic_instagram.svg',
      discription: "simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the "
          "industry's standard dummy text ever since the 1500s, "
          "when an unknown printer took a galley of type and scrambled it "
  ),
];
