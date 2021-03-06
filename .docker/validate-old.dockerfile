FROM    phadej/ghc:8.8.1-xenial

# Install cabal-plan
RUN     mkdir -p /root/.cabal/bin && \
        curl -L https://github.com/haskell-hvr/cabal-plan/releases/download/v0.6.2.0/cabal-plan-0.6.2.0-x86_64-linux.xz > cabal-plan.xz && \
        echo "de73600b1836d3f55e32d80385acc055fd97f60eaa0ab68a755302685f5d81bc  cabal-plan.xz" | sha256sum -c - && \
        xz -d < cabal-plan.xz > /root/.cabal/bin/cabal-plan && \
        rm -f cabal-plan.xz && \
        chmod a+x /root/.cabal/bin/cabal-plan

# Install older compilers
RUN     apt-get update
RUN     apt-get install -y ghc-7.0.4 ghc-7.0.4-dyn ghc-7.2.2 ghc-7.2.2-dyn ghc-7.4.2 ghc-7.4.2-dyn

# Update index
RUN     cabal v2-update

# We install happy, so it's in the store; we (hopefully) don't use it directly.
RUN     cabal v2-install happy --constraint 'happy ^>=1.19.12'

# Install some other dependencies
# Remove $HOME/.ghc so there aren't any environments
RUN     cabal v2-install -w ghc-8.8.1 --lib \
          aeson \
          async \
          base-compat \
          base16-bytestring \
          base64-bytestring \
          cryptohash-sha256 \
          Diff \
          echo \
          ed25519 \
          edit-distance \
          haskell-lexer \
          HTTP \
          network \
          optparse-applicative \
          pretty-show \
          regex-compat-tdfa \
          regex-tdfa \
          resolv \
          statistics \
          tar \
          tasty \
          tasty-golden \
          tasty-hunit \
          tasty-quickcheck \
          tree-diff \
          zlib \
        && rm -rf $HOME/.ghc

# Validate
WORKDIR /build
COPY    . /build
RUN     sh ./validate.sh -w ghc-8.8.1 -v --lib-only --extra-hc /opt/ghc/7.0.4/bin/ghc-7.0.4 --extra-hc /opt/ghc/7.2.2/bin/ghc-7.2.2 --extra-hc /opt/ghc/7.4.2/bin/ghc-7.4.2
