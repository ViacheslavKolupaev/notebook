# ########################################################################################
#  Copyright (c) 2023. Viacheslav Kolupaev, author's website address:
#
#    https://vkolupaev.com/?utm_source=c&utm_medium=link&utm_campaign=notebook
#
#  Licensed under the Apache License, Version 2.0 (the "License"); you may not use this
#  file except in compliance with the License. You may obtain a copy of the License at
#
#    https://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software distributed under
#  the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
#  ANY KIND, either express or implied. See the License for the specific language
#  governing permissions and limitations under the License.
# ########################################################################################

class Solution:

    def is_palindrome(self, x: int) -> bool:
        """O(n)"""

        # Negative numbers cannot be a palindrome because of the minus sign at the
        # beginning. Adding base case processing.
        if x < 0 or ((x % 10 == 0) and (x != 0)):
            return False

        x = str(x)

        if x == x[::-1]:
            return True
        else:
            return False

    def is_palindrome_without_str(self, x: int) -> bool:
        """O(log(n))"""

        # Negative numbers cannot be a palindrome because of the minus sign at the
        # beginning. Adding base case processing.
        if x < 0 or ((x % 10 == 0) and (x != 0)):
            return False

        reversed = 0
        print(f'\nStart loop with x: {x}')
        while x > reversed:
            q, r = divmod(x, 10)
            reversed = (reversed * 10) + r
            x = q
            print(f'q: {q}, r: {r}, reversed: {reversed}, x: {x}')

        print(f'End loop with reversed: {reversed}, x: {x}')
        return x == reversed or x == divmod(reversed, 10)[0]

def test_solution() -> None:

    assert Solution().is_palindrome(x=12321) is True
    assert Solution().is_palindrome(x=1221) is True
    assert Solution().is_palindrome(x=121) is True
    assert Solution().is_palindrome(x=-121) is False
    assert Solution().is_palindrome(x=10) is False
    assert Solution().is_palindrome(x=0) is True

    assert Solution().is_palindrome_without_str(x=12321) is True
    assert Solution().is_palindrome_without_str(x=1221) is True
    assert Solution().is_palindrome_without_str(x=121) is True
    assert Solution().is_palindrome_without_str(x=-121) is False
    assert Solution().is_palindrome_without_str(x=10) is False
    assert Solution().is_palindrome_without_str(x=0) is True

test_solution()
