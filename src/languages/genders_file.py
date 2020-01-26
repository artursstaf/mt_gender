from languages.util import GENDER


class GendersFile:

    def __init__(self, genders_file):
        with open(genders_file, 'r') as f:
            self.genders_tags = f.read().strip().split('\n')

    def get_gender(self, profession: str, translated_sent, entity_index, ds_entry) -> GENDER:
        if entity_index == -1:
            return GENDER.unknown
        line_number = translated_sent[0]
        gender = self.genders_tags[line_number].split(" ")[entity_index]
        mapping = {
            "U": GENDER.unknown,
            "F": GENDER.female,
            "M": GENDER.male,
            "N": GENDER.neutral
        }
        return mapping[gender]
