{s}: rec
{
  ghcidScript = s "dev" "ghcid --command 'cabal new-repl lib:fantastic-morphisms' --allow-eval --warnings";
  allScripts = [ghcidScript];
}
