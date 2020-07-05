# frozen_string_literal: true

# Copyright 2020 Steven Ensslen
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# The name that the Hugo nomination process used is no longer acceptable
# for Hugo voting.  Keep all the nominations, and change the name
old_str = "Astounding Award for the best new science fiction writer, sponsored by Dell Magazines (not a Hugo)"
new_str = "Astounding Award for Best New Writer, sponsored by Dell Magazines (not a Hugo)"

hugo = Election.find_or_initialize_by(name: "2020 Hugo")
astounding = Category.find_or_initialize_by(election_id: hugo.id, name: old_str )   
astounding.update_attributes(:name => new_str)
