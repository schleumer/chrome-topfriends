distfile="chrome-topfriends-dist.zip";
prefix="chrome-topfriends/";

if [ -f $distfile ]; then
  rm $distfile;
fi

git archive HEAD --prefix=$prefix --format=zip -o $distfile;