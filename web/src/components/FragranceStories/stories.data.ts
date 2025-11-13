export interface FragranceStory {
  id: string;
  title: string;
  subtitle: string;
  tags: string[];
  teaser: string;
  notes: string[];
  description: string;
}

export const stories: FragranceStory[] = [
  {
    id: "springtime",
    title: "Springtime In A Park",
    subtitle: "Replica Eau de Toilette",
    tags: ["Top Notes", "Mid Notes"],
    teaser: "A luminous journey from dew-drenched petals to radiant lily blossoms.",
    notes: ["Pear Accord", "Lily of the Valley", "Jasmine", "Soft Musks"],
    description:
      "Sparkling pear and blossoming lily mingle with jasmine petals, wrapping you in gentle radiance reminiscent of morning strolls under trees in bloom."
  },
  {
    id: "after-rain",
    title: "After Rain",
    subtitle: "Replica Eau de Parfum",
    tags: ["Top Notes", "Heart"],
    teaser: "Mist-kissed greens and mineral clarity evoke a tranquil evening storm.",
    notes: ["Ozonic Mist", "Vetiver", "Pink Pepper", "Cedarwood"],
    description:
      "Fresh rain accords cascade over crisp vetiver and gentle cedar, leaving a luminous trail with a hint of peppery sparkle."
  },
  {
    id: "evening-saffron",
    title: "Evening Saffron",
    subtitle: "Replica Extrait",
    tags: ["Spice", "Amber"],
    teaser: "Golden twilight spices unfolding into velvet amber warmth.",
    notes: ["Saffron", "Rose Absolute", "Olibanum", "Ambrox"],
    description:
      "Textured saffron threads fuse with rose absolute and glowing amber, capturing the hush of sunset over gilded city rooftops."
  }
];

