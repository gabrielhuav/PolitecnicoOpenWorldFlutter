enum NpcType {
  person('ic_npc_person'),
  car('ic_npc_car');

  final String drawableName;
  const NpcType(this.drawableName);
}

enum CarModel {
  sedan('WHITE_SEDAN', 'White_SEDAN_CLEAN_All_'),
  sport('WHITE_SPORT', 'White_SPORT_CLEAN_All_'),
  supercar('WHITE_SUPERCAR', 'White_SUPERCAR_CLEAN_All_'),
  suv('WHITE_SUV', 'White_SUV_CLEAN_All_'),
  van('WHITE_VAN', 'White_VAN_CLEAN_All_'),
  wagon('WHITE_WAGON', 'White_WAGON_CLEAN_All_');

  final String dirName;
  final String prefix;
  const CarModel(this.dirName, this.prefix);
}