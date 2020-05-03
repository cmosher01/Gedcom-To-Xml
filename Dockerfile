# Gedcom-To-Xml
# Converts GEDCOM file to XML format.

# Copyright © 2019–2020, by Christopher Alan Mosher, Shelton, Connecticut, USA, cmosher01@gmail.com .

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

FROM amazoncorretto:8 AS build

ARG calabash_version=1.2.1-99

USER root
ENV HOME /root
WORKDIR $HOME

RUN yum install -y unzip

ADD https://github.com/ndw/xmlcalabash1/releases/download/$calabash_version/xmlcalabash-$calabash_version.zip ./xmlcalabash.zip
RUN unzip xmlcalabash.zip && rm xmlcalabash.zip

COPY calabash.sh /usr/local/bin/

COPY gedcom.xpl ./
COPY lib ./lib

ENTRYPOINT [ "/usr/local/bin/calabash.sh" ]
