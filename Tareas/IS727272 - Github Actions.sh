echo "Hello World! at ${{ date +"%d/%M/%Y" }}";
echo "PR Author: ${{ github.event.pull_request.user.login }}"
echo "Last commit: ${{ github.event.head_commit.message }}"
echo -e "Commit diff: ${{ git diff origin/main HEAD }}\n"
