FROM base/archlinux:latest
MAINTAINER hue-plu <shuetwitter@gmail.com>

ARG ARCH_DE_PASSWORD=default

ENV LANG en-US

# package setting
COPY pacman.conf /etc/pacman.conf
RUN pacman -Syu && pacman -S --noconfirm \
    pacman-contrib\ 
    base \
    base-devel \
	zsh \ 
	git \
	vim \ 
	fzf \
	emacs \
	ripgrep \
	alacritty \
	the_silver_searcher \
	xf86-video-ati \
	&& paccache -r

# add wheel group permission sudoers
RUN echo "%wheel ALL=(ALL) ALL" | EDITOR='tee -a' visudo >/dev/null
RUN visudo -c

RUN groupadd -fg 999 hueplu && \
    useradd -r -u 999 -g hueplu hueplu -ms /usr/sbin/zsh && \
	gpasswd -a hueplu wheel && \
	echo "hueplu:${ARCH_DE_PASSWORD}" | chpasswd

COPY .bashrc /home/hueplu/.bashrc
RUN chown hueplu:hueplu /home/hueplu/.bashrc

# -- above root user
# -- below standard user
USER hueplu
WORKDIR /home/hueplu

COPY askpass askpass

# skip sudo prompt
ENV SUDO_ASKPASS /home/hueplu/askpass

# pacman AUR manager use yay
# sudo -A ls ... is workaround to use askpass
RUN git clone https://aur.archlinux.org/yay.git && \
    cd yay && \
    sudo -A ls > /dev/null && \ 
	makepkg -si --noconfirm

RUN rm askpass

# ENTRYPOINT alacritty
