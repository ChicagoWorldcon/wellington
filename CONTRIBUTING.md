# How to Contribute

Worldcon is a community brought together to celebrate science fiction. Without community, this event wouldn't be great.
Just like the con itself, we need helpers and contributors to make this software great. We want to keep it as easy as
possible to contribute changes that get things working in your environment. There are a few guidelines that we need
contributors to follow so that we can have a chance of keeping on top of things.

## Getting started

1. Make sure you have a [Gitlab account](https://gitlab.com/users/sign_in#register-pane)
2. Check the [list of issues](https://gitlab.com/worldcon/2020-wellington/issues) to see if there's already a
   conversation about your feature/bug
3. If there's nothing there, [raise a new issue](https://gitlab.com/worldcon/2020-wellington/issues/new) with the
   as much detail as you can, including
    - a clear description of the issue,
    - when it is a bug, steps to reproduce the behaviour,
    - information about the  application version and operating system,
    - note, a ticket is not necessary for trivial changes.
4. [Fork the project](https://gitlab.com/worldcon/2020-wellington/forks/new) on Gitlab, make changes if you can or just
   a test if you can't.

## Making changes

* Create a topic branch from where you want to base your work.
    * This is usually the master branch.
    * Only target release branches if you are certain your fix must be on that branch.
    * To quickly create a topic branch based on master, run git checkout -b fix/master/my_contribution master. Please
      avoid working directly on the master branch.
* Make commits of logical and atomic units. Ideally, no commit should break tests. Commits are a story which talk about
  how you went about doing your work.
* Do check your files with linting rules, either by running `rubocop` or by getting an editor plugin
* [Mention any issues](https://gitlab.com/worldcon/2020-wellington/issues) relating to your change. For example
  ```
  Rework guide, move OSX specific instructions into it's own file, issue #1
  ```
* Trivial changes that are not specific to issues don't need this. Please instead mention `(docs)`, `(maint)`, or
  `(packaging)` as appropriate. For example
  ```
  Rework guide, move OSX specific instructions into it's own file (docs)
  ```

## Linting

Please use `rubocop-github`. It's better to be consistent, and this just seems like a good line in the sand. There are
plenty of nice [text editor integrations](https://rubocop.readthedocs.io/en/latest/integration_with_other_tools/) to
get a quick feedback loop going while you work.

This is checked in merge requests along with the tests. Using rubocop helps us with readability by keeping the code
style consistent, and helps keep the complexity down with best practice advice.

## Tests

Tests are best effort verification that the system is running fine. They need not be exhaustive, but they do need to
describe the behaviour of our application. If you are submitting code, we ask that you please also provide tests to show
how it's expected to behave.

Tests are a love note to the future.

For more information about how to write tests, browse the [spec](tree/master/spec) directory. For documentation on
rspec, please check out the [rspec website](http://rspec.info/).

## Licensing

This project is distributed under the Apache licence. We do this because it's an open licence that allows us to release
our work without worrying about legal liability, patient infringement and other stuff that gets in the way of good code.
We ask you to update files in the project because they might be copied between projects in the future, and we want to
respect the original author's work and copyrights.

If this is your first time contributing to the project, please add yourself to the [LICENCE](LICENCE) file in the root
of this project. Try put this in alphabetical order with the current year.

If you're modifying files in this project, please make sure you add yourself to the top of the file in alphabetical
order with the current year.

If you're creating a new file in this project, please add the following boilerplate comment in the top of your new files

> Copyright [year] [author name]
>
> Licensed under the Apache License, Version 2.0 (the "License");
> you may not use this file except in compliance with the License.
> You may obtain a copy of the License at
>
>   http://www.apache.org/licenses/LICENSE-2.0
>
> Unless required by applicable law or agreed to in writing, software
> distributed under the License is distributed on an "AS IS" BASIS,
> WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
> See the License for the specific language governing permissions and
> limitations under the License.
