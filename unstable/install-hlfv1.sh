ME=`basename "$0"`
if [ "${ME}" = "install-hlfv1.sh" ]; then
  echo "Please re-run as >   cat install-hlfv1.sh | bash"
  exit 1
fi
(cat > composer.sh; chmod +x composer.sh; exec bash composer.sh)
#!/bin/bash
set -e

# Docker stop function
function stop()
{
P1=$(docker ps -q)
if [ "${P1}" != "" ]; then
  echo "Killing all running containers"  &2> /dev/null
  docker kill ${P1}
fi

P2=$(docker ps -aq)
if [ "${P2}" != "" ]; then
  echo "Removing all containers"  &2> /dev/null
  docker rm ${P2} -f
fi
}

if [ "$1" == "stop" ]; then
 echo "Stopping all Docker containers" >&2
 stop
 exit 0
fi

# Get the current directory.
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Get the full path to this script.
SOURCE="${DIR}/composer.sh"

# Create a work directory for extracting files into.
WORKDIR="$(pwd)/composer-data"
rm -rf "${WORKDIR}" && mkdir -p "${WORKDIR}"
cd "${WORKDIR}"

# Find the PAYLOAD: marker in this script.
PAYLOAD_LINE=$(grep -a -n '^PAYLOAD:$' "${SOURCE}" | cut -d ':' -f 1)
echo PAYLOAD_LINE=${PAYLOAD_LINE}

# Find and extract the payload in this script.
PAYLOAD_START=$((PAYLOAD_LINE + 1))
echo PAYLOAD_START=${PAYLOAD_START}
tail -n +${PAYLOAD_START} "${SOURCE}" | tar -xzf -

# stop all the docker containers
stop



# run the fabric-dev-scripts to get a running fabric
./fabric-dev-servers/downloadFabric.sh
./fabric-dev-servers/startFabric.sh
./fabric-dev-servers/createComposerProfile.sh

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.15.2
docker tag hyperledger/composer-playground:0.15.2 hyperledger/composer-playground:latest


# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d
# copy over pre-imported admin credentials
cd fabric-dev-servers/fabric-scripts/hlfv1/composer/creds
docker exec composer mkdir /home/composer/.composer-credentials
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer-credentials

# Wait for playground to start
sleep 5

# Kill and remove any running Docker containers.
##docker-compose -p composer kill
##docker-compose -p composer down --remove-orphans

# Kill any other Docker containers.
##docker ps -aq | xargs docker rm -f

# Open the playground in a web browser.
case "$(uname)" in
"Darwin") open http://localhost:8080
          ;;
"Linux")  if [ -n "$BROWSER" ] ; then
	       	        $BROWSER http://localhost:8080
	        elif    which xdg-open > /dev/null ; then
	                xdg-open http://localhost:8080
          elif  	which gnome-open > /dev/null ; then
	                gnome-open http://localhost:8080
          #elif other types blah blah
	        else
    	            echo "Could not detect web browser to use - please launch Composer Playground URL using your chosen browser ie: <browser executable name> http://localhost:8080 or set your BROWSER variable to the browser launcher in your PATH"
	        fi
          ;;
*)        echo "Playground not launched - this OS is currently not supported "
          ;;
esac

echo
echo "--------------------------------------------------------------------------------------"
echo "Hyperledger Fabric and Hyperledger Composer installed, and Composer Playground launched"
echo "Please use 'composer.sh' to re-start, and 'composer.sh stop' to shutdown all the Fabric and Composer docker images"

# Exit; this is required as the payload immediately follows.
exit 0
PAYLOAD:
� XwZ �=�r�v�Mr����[�T>�W߱je��y�� �H|I�l_m340b���B�n�nU^ ��wȏ<G^ ��3�������kN��>}����>���f(-d��1,�h��0G��m��� �!�g8&p�Oa��>��b�p,���a^x�{�.8�M �&��l�E��R�"�R}l	[c!��*��a �9a����/݆���s���0�f�m��i�~��5����E��m�$��mn��!�m�4�wU���H�H����aI.�'��lf��2 �8�F�U�Y���v<}��F6�Ab�����Ŀ�����qO`4�!S��U��S 馡i�a%���&��JIN�+�!ڦ�(�6,P�d�:�\ܙ���\O��⹡#�ƝvduUC�;X�����a�T�yͯ!K1Վ��7�a M�.��Q�q��.?����P+نI�CM����8Nh<x5<�*Ԭ���md8d��7�0k��Sn����!-������B� ��펆Hvb\��=��gO�9�P�iEjt� iN���ɦH�C���JG�p��bKq��7m��ۯ����N�_\$"��9��쮛!�`����胃,�R<�3��Mm��>���x2ߖb�������� �Ѵx�#�׌��a��RCu�h��.md�P�%�{׹��|�]��j� �?���{��(y�Xd��G`��E�8���D)��S��FX�2z�����u���^��a>"rd�c�����U��?����B��X�c*��O�R�5�$+&��1!���K��bR~˽�f�3����j�[�\3 V6�d����_#L�"�d8?��s�������u����7��С����r����_���z�_	����)�߁J6P��2�{����ř�K���q-�� �t:�nN�@�y�Y.��n�kid�M��m ҳ6��u��&���f�e��cόWo�T�x+��m�A4�D8_��?�=���^~G��
ᜦS%N���3
�04+H�3�S����4�I�s�+��
�-Z�������&���F�,�*pY���4��k�Z���#��ʺ�l��[uT����T��h�m8Z�x�AН�!���x�(��)�Az銊|4	&���p0�ij�q��Y|Pz��,<�^N|"gP�R�5s���@����4-EO��5�Ν���Xl������-����	m�R5@�L�6�'"`:���ѡ��Y��y����0G�����B�c���g�Zo�6y�c���e��������4����m���Y��+�6�x5P>)e���ʅ�ʡ�vaf�E��A����lJ��kҋ�a�^�����!Lb�c.
����������q��<�U±�a�@�ǤѮ����!3Ou�Xd���d���g�G��?1�]������.LA���vI��c�j��{�\�QmZ��^3�׾����0G��.{�!h!`!)6�5U�	�ـW�eܯ��S:9��v6b�^G ��9K*c�1��T��G����pz��p#*H��gx�5Y�3*N/�b�����q��!��5/o��a<t��^:����������d"ݛ������H4���Wk���S�4��T���E!:)�<����\=)5�øڙ�t�>�)���LCc��fLXuu4�4	�h`��0�L*[���Մ)�eK�d1{T��/M�+Ʊ�x�]�3�6?����KTW\a%7-%�����\,e��/�GZ���! ��n!���-�M*p�1�%	\�v��Bi�MS$����xf�*7�-��b����ɇ��l��Ц��G�S���Y�n4a��.q�@�B�n��-���I�r1� o߂ͩ��	l���	�-g���X�@w�Ud����K����%}����:��u+�dx�]�!o���h!vrZ`v|�_�6��o`�y�����?!z��C�����
���?jUS����0u:)���(p^�M��\��9 <k�����E��H@��д�� \$�a����b��������?��Sվ'z�T���@ �u�6rLxȠ����Υa��O(L��q�����߫���OM��f���0�d���E����:�%p��_�R�"�O���pt���&�eb�:6�M��4�蘪n{��6�kV�!&x u�n�lr�E�Q�7�D�TL�����m?��e��(��~"L��tlz�Gi�<�$,�c�-�	2��ӊ<%bx��2�I���J��A�>�B.ǻΘ�[!	��3M�P�F��l�<1� `�����L��j�*D�&O]�	�э�Џ��ht�b�;V�����3g�����+]���V�n�4}�r����2�B��1q2�;�p�����J�+Y5W��9^���Z
i�蔳
r|�kAfDJ��@�O�=�� ����_�w�V�޽K�����0�Y���?����e.�,�,���(D���J`��{��0'}���	VS��r��p/W�,8�x+n �s#/�"c��51��2«aԛ�Dj������`�#��tS���<󎢮��h������ x_Н�k�d�f�������P��Uk�*����{����{�详b����OSIwl>�ٰg�`]e�D\>��ȹYv�8!�醳1I�	�k�Ƙ��<.o���{��.d�j]%�|�0��������QSBo�0^Թ�!���,S�k��H�G7��ޭ�uӰl���9
�����GB�ʈ���xVLy�c�)��/u��5�8Ǵ�8�
���o���5��s���k��2�m��wm�k�3���RY>ߗOwoXVx��wl�4u�A_�4��^A���y\�
ѝ�����n�E��y�*�b�j�Sb�an��GuE�n+qQ#�TڮAN	�����W��q(��ع�b�r���-��Y�� ��jӠ��"�7[��t0܂�|1��V;Z��4l�O)M�y�]�@�3]rA�� ��6�}x]�h��h"�4ӏm��Sx��K#�g�� �e�3�M����gKO_z� �i�z|�RJx[�k5ҽ�Q�en�	�붃o��-������_�@����
�����Hu˶�h�X�Lh���O�	��2�8���|�K���O
Zx�+:)�bLX��Z	,+�c���q*��?\1:}l�4 t7�Q>�~�-CZ�S��v�K��T�3e ��#���F�i�kڌ�g��\��&�綾�M��/1��1�=�b���,�9Z�7F�;#kó�Y7��� 0_S|�on��V�O��.�������:�cp��-b���/�Ax��/\$6y������+���eΙ��}����������+��'��F�*���߮+�qX��Ee;�֫qAb�<�b��
�x��ƶ#Bu;���o�?�Lސ6���[��ш�+"��w�_��m�����4t�0m�io���?0�l���}���oƉ��7�}3�ò��K���獿��/6��߿�Mv�a��>1��jZ���#��0��SD$�ԇ�%p~�>o���y�.�TýSw_���z�_|��=���c��/�1����U�G�����15�NZ�_� �/XX���
݇�X�{�-�Sٝ�,9�P�F�>v�,{t��P��>��CHL<@ !g�y@�'��lR*�4����f���dRR���MH�lQ�;��q�y�Jd�ƛ�j�-��K6N���Y�ꂓ1nO��0������h��ǹK�J*&�cL��l�Ռ֮�_;�D�L_H7O)��q��ȼӕv�9��Sa�2S�޸FY���gW�s��٬�IXg��EU�.�RtqreY�7���������ϕ�^�"+��YNH�M�i����D5W�z��i�P�Ƚ�Ǖ+���GZ�L��Bڂ'g]�霖�\���2��W�������'��&Q���G1�^�pR��ID�}��JeҶ�����n��8�=��e��RN�K9�Lz�{��e�D��޿L�L�T��X��z�r��)�'���Ğ~�:9�i�J��K�iX+�j$;��uz��|)��r��b�L���Fo��\N�$�涖�ɉP�@�x���r������Tߖ�I�%-ҪZ�Wh��R6�6ϠKd�w�Y<h���:m,Yxxhr�t4�
�#{x�;9���`R�RN�$���h�������P-�"q^�#'�PS?{Ke#���Tz��n�jd��~�h�_�kFڐ;P��r�Sz��9��AN�'�x�[�W���;�Ny9��"���u0�|`�Uo=��[��^?���Ș.��|������3���4{ޢ�_)|����� O;~aE���O���y~����I^�ؗOi�c&����=Y��G'2\�Php\�wp��7�P\mU����C�+�oP>s�i]-�B�Uq��N�\II*�ݤU�䋝\�u�����c��Ԍ�U�ẍǭJ�P��#iE*�{BFm$�'z�0���H�T�����j�D�i䒏���w�a��׿X���{A����"$$d-�+�9v����,k%1�I̲6����,k!1�H̲���y�,k1�G�4ۈ�i��c��_��'޴�"k�o���?������G_��'L��ֿ������A6�7�ҭ��;�����T�x)���
I���)�SXN��]�4��ţ׍<j�3�a�,�k�Hq�go��t1�4�8�����+[�ۺt��,�w���:z���)����7�&9�ܽ�ہO�߭�`���u,�����ߑ���VO@���M�M��_f'$ME�f�"��d��(��ԛ����7�,��"s�~��a��������f�bA �P]�U1k�IT��ZhC6�UI/j�F�>xq�,��!?-}��	=��� y�#أ Hm��;�_K��nB�-u�BG���rEzT�f�h*Yj�}5�L=7���o���a��/�{s��'򠽷��$��A��������A'o������=}�~E'�,�=
�I�:���aUs�B�$�M�ɏ����L'�@�pL���Q;&�WA rЛ��G0�A�>�L^[-#�}�F/\it)xth��@P�4a�TH1_��"Ӗ�0J듺-zo��=�B�y��dB� xZD��@�I���AEP^ ��{/dЃ>:��޳�8�d53;Eΰ;�w>4��0ߚn;��b[�Lg�N���t�l�Hg:����L;m�5��#���� n �!�����
����!n�""?N�\����]��V��Ȉ���������c7>�b���q[��r��^����`M��Lu_� n>�l���.р��a�Ύ�	�pcĮ|���~�?~�������@��42���c;�v��E�A}@#')�@�$���)9U�	B��j,�j������M��#wR�%�S.���v%<�0/�F����0�?�VP��F!�u��݈���$L/I_�s�)���T�Lg�m��P�4F�9��J�I0U�+"�F�o�K F<��ËTb��~�Cս��!Ɠ3gc��]ǜA�\�%j��*�KB�#\��O]�n�_1�|5V��Q����u3 ��庮@�ɞ�z�L*�s�������ވ���
*5��34 �����
�x�UR6��c�n$+T;д��!�n�0_�Ս{9��C��c�C�:z 7�g��݋��H<�t����V���!��$�[;�}�~�4=~sxhrw�Բpl������H����C�,�Jc�(��N��S�;j���]�����MC	m=�AL�����?��Ƕ��)�zq��<��}2^�"��?����s�/ޟ�U�o�x�s�����������7��K�w)�3��E,�_�{�͗￶�C|W�u�u��ԕO��H�3qE1��+�TZ��x"-+q*�����L%��D/K'�dF�h:��,���$-G�G���W����7��G��~����©~������D~'F|7��X��&^_ߢ�"�v�o�`���"�˻��o���{�W�f-�o�"_܋��=�=���߽�i�c�::WG�1x�+��A&�:��R��&����r��i��Y�V�s��BG��mώ��c"tv�ٞ[x �w��=�5���(uh~F��Ȩy'���Z<�,ĳzR<���t��A!�EnŔ�����ǒ����;��^L���R��q�~W�J�]Hh�qi �*�]�����wp�#~������q�Ӧ�Кu�-6���<�/*g�frw�lT�:M�:,��auTZ�#�|>����MڎtޙXG�ʮ�71,C��|�To7�C����ʼI�;s��h�`�� T�b>�p���X���,�^+�D&���Kp|D�S �<��8��3Kn�à��3�g��/hu� l�<m�Z����Ĝ���-%���H���,w���`r��6��d���rz5Zg6��&��"�1����JM�I"g)=��:*ϴ�P81z�d
��͖�`
�3��)�����#a�J<Qc����|�����F%/�J����_%^m:��L�J�p-�49$v���O$��e�VT�R�ƌFn��(v���Yc�Bl+�Ŋ@��ˈ%��έE�d��DO�)�
${�E7&o'~_����Zj6�5
��,�`��A���m=�mK���Ҙ�3�.�CEVh�OJ�~N����J�[ �m8����L)ڜ8&�'����˟�?���rL6D��W櫓*m�b0g+��!���s�R�Sf��D�J3>�M��(�ԒN�b[��w�ZV_&�v)C%�9�9)��9gT�CZ�գc=�궪�^�Pb}��~n4ϤF�T\؍ߏ���ˑw"{����W�^��:���iA������K���oV"�!�m�-�^-�P��{�ȇ�7�����~����/��D=H����Šߑ�l˫�W"/��X��A��I���ׯ�C�ȏ�~�O<����E�/�{���(�ϯee�de
X�|��̫���5������IJ��.�| =k��瘦/�s�6�����X8�I"�ǜ����,B��s.�6Zs�s.�;��.����'"��9p1߰�B �-1��<a!�k�!������q�n���ӳT.U:�&55V'��Z�=?R�#�R��S<�G�ZW?�RLn$�=kRp�E7�X�~{u2ʗ4]���M*�'Su�L�x,�A��H�N��:<��pL-����i1*�0.(�V��d~5�Y&��L�_8���6(��-�\'�4mF�W��!(�J��X���D]k'����蘊I�I:1<�BB�%�h�[N��J�&�Uc��\��ر:H�Aw>.���R"�D��.��`x�>���M)�r�(�;�� �FuqV.�r��f�����<s��Y����m9�b�}�U�|$�b'���E������
7\V�	n�9�g|�'w���;�u�3��5����6f���D8^B�J�ՙb[z;_��0j��)XҬr����qS���ö^oM��*?��(�v�i��Y
.���B�g���0ڭ0�f�Ryk�W�q\E�w��0ΑK,gl��&��G1ij�ZB����\3���t{p~�tbO#h�u.k�BI� ��`�.̎z'��Z���b{(��	_j��%���gλ"_\4$���B��抺���~o�tl��P�R���R��43�U��S��y-MT$$H�kA"V��d|��g"�e�� ��Z�#s�W��N���"��q�-��`aB�v�&�Z�R� ��I��@!�k��J�4��[ǽ����J�OԒGF{�g�|!6��9���̼[o
ͯ�	&��T�I�.S���j�ǃB�Xefs�ȬS$Qn+P_��(�V�#�����x� �jXc�����b=yp�ҋ7%� !�-����f���D)Y�3*����Ĝ�d5f>"�T)�y W��ފ�i.:�ɎȦv}��Q.a,�n���6��Q�"�@/���ҏ"߄:���^���a�-(Dz�����*�:�/�<]��Z�TwO�"{~���L�,��U��̒�5�f�5�U�4� �>�3,�{���R#oE^�#�|��	��'d���8��:ʋ|5�*�
����	�5�aCW\B_���	]�(��7���c�14��jOx,3����q?8`�@qΦx���>_�ě��0�2U-K�"��}�]��)|��=:^����������e�[��!{"{q3�_�\s�K�/��IЉ����_$��{���$=��ޯ$���*�;�a��{9�����*��������$˳S0(`�0#����M/��횊L�LU������:$ϰ	S��c�1��O�v���|�[��'�ε��62l���,K�q�d����n�x�z�55�z��HW��h��z�l!�;�&����zWH�tM�7���u�<C� ����� =�X��ѵD6E����� 5 ��)�]#�o*z��5̾] �3໠o`LB����G��g�.���`����
9V��B�B�]<S�2s�K��>��_����jضʄ5LC�p.j< ?�A�����Z� o������!��·��}�a�޹j�l�������A��}Ը4�C�Ej�P�(�L���. 3�A���>�m[1kr�N�=��V��J6p' �:$7C�A�C�t�b�Xd��G$0�*�2�^�<��� �kS}��'�8$&�(�"�7���j�O�t"�r����5�F7z���3�{s��lq��¯6f�[�mS��w� ����@25-����}�������Ytz���zM�9�,Zװ|���p����o~bH����7��ć����[�f"KJ���$���je}�ZY�ٙ�8�0� <�'�~<��[̜b`��9�w%k�زu�pݍ�q5�����^2�6\3N���]ET
����ط���p/c���!�>ڗ��6��C���ԫ­eq���kJx@^�����w1Ho�m/!+O�t`2j�tۏ0������b8ὐC��6����g���iX[��#�d CÔ�Q O�8��!Q��ݲa��X��hW�D��`W��l�������7B��kcd8�3(�Q��҆�쎕�~�^�BNLǵ��@��թ�-e��u��Y�W�٫8�!E6ܺ־�Ŗ��M�ϼ}$�'C�o��:�Pp�lܯ5��Ո-�!�B�	�� ��l��z<�ή$I��7"G�NC5�Ss��l0�w����#8� v�X�P&VP�*�8"�P;�q�Ʀ����um�i�N?���a6��ל"|9�S��&�����,�	\��xJ[G2����m��Og��cN���Ԕ�9s�!9�|D	��#�+D�]+»��p_o8��k����.�8���k��'��v��d<���</d�!�!�!A �{�V�#��+q0��DG�C��=�<�6��i�9E��EU��	����|�o�o���X⽫J�ó�P�A��U�e�Z����<]=��Џ'S2��Lgi$�j<�O����ڧ�t������V��Ϧ@"�Q�(�-0$�B���Q�-7�N�b�A�t��~��W�%�����z�^옐`�\�Cu�t �,�SI �r,����P����@ �J%�j:�Ie�8�B��Hf�j"�R T80�ٍ�v�?'�@q�[ϡ�6RC�������@����Oy�ޓۅ�0�u���;2^C�^���m�������7��i�Z(��|����3��lBS�+�5�f�QkW�Ks��M�)�R��=�[��d�M^���%֮�T�)�͚�=
m�]�E:����`���@ yWd�
ڝ��;��h_-jM{QM�3��Ź�$Z�A�BGKFwݸ�]Ծ���pmd{�m;?L`t��X����wo����+6S.GyT�f���6x���R8��|c���\�*�*����ǳ��f�c�p��P�����0��{��9�F����[=����K��O!F^�{��S�%�������UsG�h�ڔr�J^(�Vx�]m��w�|2:_�ݬt�t�ɋ�`���Hŋ4��zx� �6%Zr�İL��3g��^�?Wm������PW��d6�x��m	�(Jy���3��K�����IB�&q��ˈ:@��M���tɇ�f���m7�o��-��~Lv��
CWԉ:V�����έ������ر[Z{��f7>�m��5���H��q�i�Q�UlNE��#m��V?������Y0��{��_�d�~��y<_r�/��:�z��1��}1�w�<�����o3�q:�x1���������.�������<������;��ım��wND�����B!D��	��x�v��ʐ�LgzkWz}�
A�	�_�j�����  �����4�?p��"_�?'���(@��O��vI���ӂJ����/�u������	��6���_������������	��_K�5
LR$SA���v��)�EID� RQ��2�	L(�b�qB�t����O������;����_H���{}L��\��q����«Z[�6��z������]�7)��ixԃ�ӟ�Fݪo�����RH���ȭ<&�;��O��s��^>�&iЧ�Lp����j���d�ˆ��t�R�)%�q���馾о}�������p���u|��?��T�:�Ǡ�����S��Q������?��T������_�����z����q��A�?����֩]�[����\�)�>��	���(��D����\�9�^�y���O{�]��@�����������P�G�	Gu�Q���Ο�G=����$`��� ��ʀ��s�?,����� �GF���C��Q����E�[�s�����Z;�NEѫ�m��p��+����K%󟑥�_�?��O�gf?o�V�z���m��x��gY6�Of�����ϗ�Ob��?Q4q>/j��l��e��N�z��ܾl'�¤.{{jx�fQ,���趝Q�U�����h�G�ږǤ�����i������'�#s��`��
����~��`�$�6WN�,t���ܙ���t�e�9���w���I�g֞8I₻����jنU�8�&�s�T�9^D�Ǒ���rs%��M����|g�d�Nj��­�nI,���+��4 
)�j���s�?,�������Ö(�`�?��D���H��O��	�?���j�������_�g��_�n����?6����?
����O����!�����x��p��ï���D��d/�<m��"���z���ů��?��_���ϖ����x���뵼�P�'!}2�E2J���ʶ������K��d�i󆿑ʥ`�J�c(FVR�E��ն5�S�;Qvᆌ���۶�Oa=���>�-�|���� Ւ��|�g���Z�[�x��o߽�¾cLe���օ&LF�Y{�ӫD['��tnM��b3�]od�t�\�N_�R�U��x�b�/kFI,�ؐԳ�I�5\��?���G=��?`���ɹدw	�� ����8�?������H�I��4��(�8"y*�D.dE��$)LȄ�P�"1��	x!��0"���8FbB2!ጀ����4����ť㛳S��{�F��b]���E:m��Tc�ekְ��,l�_��;���#۟C}zr����Y�(u�$&ӎ���O=�����Q�b'hY�鹦y��;'�8��3.k��������^p���������_@շRp��C�WX�?��T���w����U����������v����k��(2�8����7��;;=Z�|qnR�/��a��>T�^=�\�mic��s�O��t�HUO>K�3���}\k�Э���J��;Z�|YD���ˤ����A����q��!�[�����h�;���p�������/����/������j�?�� �'w�������-��_��/����e쾩�ArX���I��\?M���ǳJ��_��e�c�/��ۚ�� �Ӄ?q �W?����U���E4�:U�v��g ��1]�}ϔ��~͘�����s��Z������4V3���M�ѵ��;�9���&pv;��z*%��ޜ�L����,��|灿e_^�m����Uog 8^C)-��Lo(W�Iȳ�80�Kr��e��n����e�k'�eId�(��.�v����R��	ǙZJMm���?6�Ǘ�V	e�����"���Ї&i��F]��K��&����$ՌΊX��v;d7Ŭۑse�H��]wg����~��Z�h��Fb�������A�ܦ2ރ8�?�}��X�(���@�����o�����N ��8������`�	H�v�a*������@C������a�?���v������QR�\�!Ɋ�1E'lDR<�J�@���0A�N���E)a��
� ������A��S��������~7<�/���&˩?�	.��PVO�]�S{;d/�m�k�K����}-o2�wv�;��+�铇mK<��>�Z2Jw�/�ݸK����.G�!O��P|=�����y���T���]�d����^p��S�� ������ۊ��_%�-P\�w��y���?
���.���@��A��a�;�����W��4}����?D ������	���G��3��P����[�7R��ۇ�jh��q]i��c!_��s��]*������[��)�3�߷ǈ���������.ˑ3��'?�T+>�f�w� �'š��;����Q����͸=�M�Q�VZ��|4}/��l6���s�|�ߔ�h��QXq����~nf�9��%�M�V�՞w�߮m+Ӿ��[Y��� (�"�~g^���f�&�t�;Rm�VN������L�tO5�-L�'T=ۆ�I�E�FR}��k�fp��y�P:�q=32�3���n��uc�o�(-I8��xh�z��UV����e�۲������=8��"��?8�W ������)��VZ��Fp��!����Ӱ�	��������P���q�o�( �%�n����C��:���ӏ��,���i���_���a�o�����$�?|���P�~iկx��������	8�?M���?��T����nU��_�����UQ���r�����\����������r�
���\���@���X�T����X����� �`�ÿ������Qw�_��@�&C*�����������?��T �����@������?@��_E��CT�����a��P�����C�������? �?���� �����?����_�g��_�n����?6���p�;��h�G�?��W��C�?����C���G=��?`���ɹدw	�� ����8�?�� �?�'�����D�Ô��!�T��4bC1�X�I���q@FKF%
�RBH�r���������OA�_��{}cx�����'/��u�8��@�&Y�܀�d$i���b���C���t�qb7G��q�В��7�}��e[�����g�7�7�4U�]��R]�ka��p>w����-��g�t����àK't�u�;�;Zk@&�D��kK��ݽ���p�����?�����~U�J����_u`����S������V�f|Bp�����W�����Sm�������Z'M�֬_����٠z��Y���K�7H�{��.�K����n75�|qМt<%	��	�,9Q����{������t�95�moki�.Co�II2�qж�Yo�s6�������!����Q�G����8���Wu������A��_����U����~�����}<o��������Oi���:Rw��;��(*�s���_�������ݬ����ߤ6���$�g���x��f�k�q.my�mM6aF�(���p;ʍVG}�<R�N6��~��̨��3~&_.{i�2�m��N�o������뒸�v���;}���t��[���5��R����������g�E�9,Х�Uϲ^b7�CEE�ߵ��Q$�q�q���zfq?,ɖ�FK8��VҬ陦��8dr16�A�8$����O��A�5;sߔs��c�ZI�`mPq6_�k�$��l�s��e��t�ᄭ��wV�'������[�����_R��������������P4\$��Q���0������?mt�/lAq�\�Y��A�Q����$u_�eA�Q�F���z�N�@�����Cx��c�� �?�����*���?,��t6�q.,JR:�4`��
\j�z�GC�ݗ�*��X�.��7���^j���~X��)�G��܏���5��z���[�_�.K�^R��[�򖹼m-!���d4�J}ɴ�׬��(孡�m��F�������D�3��.��&9��j!�#Z<��kd�~�6T��%wb�9eߡl~�y���,.���e�[Sb9�������{ʾ��r��zYK%�跟eM���'�9���>}&b-srEU�3l���lW�2H�~�*��}���6K�S��y�Z���,sf�dM��\����*cۜ�G�?��c�ԓ�K�]�\B��ZfdJ���tO�,��R��޹��^���y���Hr�ڢ���y����]�����	!G�<����KR�DTp}��#)%��͟O�H`)!�#."�P�����&�?
�����k��H������r���^.B���x7��m0;$�S��8#�驯$_�����_�
��rs+����|�����}G��#��� �G	̽���|�!�1(����?�����������-�|��{����SFg[�c>N���_0@����Ɨ�:��r������v?�gr�������x/���K��%�G|_��a��r��h	^��5m�K3���;:������4�I��/ɞ��ӈ��e�DŦY�O>+b:����v�����#ޛ�{I��~A�_��"׳\��fM�a4�[��Ngm�p�ӑlL��$���|�����kmVS۲��vn����f�v��*@@��~tu���(������hNvr���Jb �2֘k�9ֲ3�4|`����	C.'�8D�0JC��z9�t�����Wt�&�ڜk���(��nc,/��檏�G�������y�ĭ���M)���J�n��2���2A$3~:���05�Rq����x��y����x^��`���������G�o�o��9�'��'�FS��ڡ3@aj����|��u��h^�9O�_�-�jA~T����k���b���Q��4����k����Ki<�jR�+<�����Y�?�e����l�A�AZ����?�U�����o�������i���TAey��6w��Pn�kg�������0lr�����序�]�}��[��D�4Ađ��@(5��ck![�屵������m�h!4.3WȏN]]f��ǥ+�����P\j�ծ+���y��pRJ��<���	����4:�T
��hV��n�h5��r�t��1>��*�p��΢�zV�)Z�v��~�Dg-��O��VSnXxl����?
���&�F��ς㻑�a���Ф6V�CʖX;쭕�+2c{[�x��[�����%�ye�ՏO���6�Twu}R��ld(��r0�{��g�
L9Z��YS�z��Vu@���d.��#k��1
�~�Ɨ
�cĀ�R��r����4���[�C�O*H���U��
���[���a���&�C"h�����:��)A�w*��O����O�����o��?ր�@.��}�<�?��g�����r�\��W�oq���� ����������A��E�^�+�|i|������� ��\����gJH������G�	���������0��
���d\0�{ ��g��~���?��,�|!��?���O�X��O9����i����?���� �������؍�_��HY�?(
��߷������ �#%���"$;�"��� 1�H�� ��� �0��/m������������9�������������S�?���?��C���7�`�'d��ǂ�����}�\�?y���RA>����B.�����������ȅ��h���Y꿥qo@�� ��o���/�W�?���r��:MกiefN�z�$z��� uS���2eL��u��MS����4�
Ɣh��>o�����/���?������'�ⰨP���_����6����R�IV��K<��:j��Ej26��Z4}Z��[ª�q�O_l�*���SQ���ս��v��{l2]=h�f�EGe:,En;,��Rm-�o�ۣtOU���Қ�n����]N�����m=�*��Q���%V��9޻���<g�C����!��?\��o����������%��?�!�n��E����3�?N����{b�N8��z1��?�Z����yf���5�_⿺0Z���`��t�ö�z�Ok
GwHL�h�*���vǴj%����\Q9�ZCi9�.���Ή��[h��S��C��Z��/��oFȲ������/�\�A�Wf��/����/�����������}��J����7���_�Y��[V�^`mԞY9����������K�r"7�pO[r_�@n��`�r���d�knz�.�aT�?�;��ߌUm4ok�Ȕ9�0.N�h\�2fΑSq�UbI�&�NS{Ķ�R�^I���j9��%�Z��6Y������W)"�*;�r��p��,�������2�h�q�a-�ޫ����(}>r~sSP��c�R�|��'ǚOd���ө�l}ǻ�.6�f�P�vŷ��z]��Q����r(��,��� �|6�/�����!��G�&�4�u	S۵���Z���{�<�?�����������S���k����(1��?��=r��̍�/�?���O/^z�A��=����������������@����e� w������Q��?� s��x�mq� ��Ϝ������
�����>�����������4 ��������\�?���/�T���� 3�����r����Cf���� �?}]��A�G*�f��)��P��?䰼o��p�cK`zzn�W�� ��=�O��X��V ?V��|��H>�3�I����I�^jۗ������n�	��.w����yZ)V��!.�H���}}^Y����i�謱�̩�:��k��O��Ìd��9>M֢b9�����_�G�~/e�ȍ�_UNk�cQ�a��T�GE�	Ui�ee�p�N�����tyb����_֙�eg"i����#�\N�<��0JC��z9�t�����Wt�&�ڜk���(��nc,/��檏�G����3`�����!s��b�����}�\�?��g�<���KH���o�a0��
�����������I������E��n�������r����r��7����F.����ߊ���$������o�5;d�+�GJ�4'�_j�_�~��I�ex���׽��/e
T�<��S@yl������v�,WU�����z^�ߔ�i�X/4��7�����W��4�����F	]<�Jt���}}Q��ƈ�z ��� $)���^�F=V���UѮ��ev_sېhWA�[fE[*{���*Z��9*��[R��Bw(v�ʝ���Q@M5s�w[�f��|��ȅ��o���_� s��i�[�>��}�<�	���X�O���B2�ZbL�Vu�RV�y	���4��p�0	+W
�MLe0ӤtCch�Rf�9M����+#�k�O��O?s��3c�閵�t�1'd$a��R�Ũ�&�^[1��1+������q3!���*ꞯ
~d�����j�HKJ�l�*�jk��+�����i�QB� 	����΢�`�>K��-����|-�����gvȴ�O�ʺ�y��!�����������"�q�uS�%����e���y��jl/D�#):ǐ*�$��k��V#[Dw�z\���%������[��*Yo�\r��ި�)��}aDM�҈�j� �[�iWj��b�mI�I��{hg�	��:Z������E>����/*������y���� p��E��e����/����/�����h�l��GQ%��[�o��?��[�豻�(Q��p��ܫ��{������j ��B /k �K+ة+����-��3
Z��j�j���Q����,ђ�����H���?�ץ�R���6�(Z/ϊ�m�[-xny�\�!���T6�u�t�x�r=�r\wXc�dL0���P�&�e� r�`��y"�~�ֽrYrá������67�0��4%��!���=���b#��r6QV�C}.��r�Ӿų^D�0�<�4a�nzJ�hy��3#����V�!{\Y�c���H���F!yJ,�6lz���B}D(�V�ͬ�|8%{xiZ��r�����D�F�9��Cxx]�����X�}��I���4p��-�-�_�������;�������m�� �\O�?����j��������oLge��_N�,��c'(|��Bor���,<|�}}����d����U�5V�S�_������I����[�������-�|@��}���$�<��}�7��p�x��{�NL���������㢚��pp���-�����7�?��aA]��'f����	���������ǻ���I^�|a{|���\u���_ə%_�
�m��������HU�����?
�����x|�����~�c�=����b������+���/�ǯ�"�Oz��]�Ǆ�<�秺��L����wϽ���<׫�m��N��
�ɍFj܄��/Ԏ�ᯌ�e���S7��)>�qu5>��<�rP������:�UX�L�j�� ��Ϲ�?`{���)�����{���'���f�����)����cG��ax_�_ݙK���;��9�C/x��c��_��/���)>l
7B��b0
���KN�5B���t��<�Xe�_����_���gw�!�����#���~�o�DYz�Ϯ."�U�	?��)��޽�a��~о���/kB               �R�8� � 