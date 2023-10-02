echo "Hello World! at $( date +"%d/%M/%Y" )";
echo "PR Author: $PR_AUTHOR";
echo "Last commit: $(git show -s --format=%s)";
echo -e "Commit diff:\n$( git fetch && git diff main..HEAD )\n";
