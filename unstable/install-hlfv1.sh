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

# pull and tage the correct image for the installer
docker pull hyperledger/composer-playground:0.15.2
docker tag hyperledger/composer-playground:0.15.2 hyperledger/composer-playground:latest

# Start all composer
docker-compose -p composer -f docker-compose-playground.yml up -d

# manually create the card store
docker exec composer mkdir /home/composer/.composer

# build the card store locally first
rm -fr /tmp/onelinecard
mkdir /tmp/onelinecard
mkdir /tmp/onelinecard/cards
mkdir /tmp/onelinecard/client-data
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/client-data/PeerAdmin@hlfv1
mkdir /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials

# copy the various material into the local card store
cd fabric-dev-servers/fabric-scripts/hlfv1/composer
cp creds/* /tmp/onelinecard/client-data/PeerAdmin@hlfv1
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/certificate
cp crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/114aab0e76bf0c78308f89efc4b8c9423e31568da0c340ca187a9b17aa9a4457_sk /tmp/onelinecard/cards/PeerAdmin@hlfv1/credentials/privateKey
echo '{"version":1,"userName":"PeerAdmin","roles":["PeerAdmin", "ChannelAdmin"]}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/metadata.json
echo '{
    "type": "hlfv1",
    "name": "hlfv1",
    "orderers": [
       { "url" : "grpc://orderer.example.com:7050" }
    ],
    "ca": { "url": "http://ca.org1.example.com:7054",
            "name": "ca.org1.example.com"
    },
    "peers": [
        {
            "requestURL": "grpc://peer0.org1.example.com:7051",
            "eventURL": "grpc://peer0.org1.example.com:7053"
        }
    ],
    "channel": "composerchannel",
    "mspID": "Org1MSP",
    "timeout": 300
}' > /tmp/onelinecard/cards/PeerAdmin@hlfv1/connection.json

# transfer the local card store into the container
cd /tmp/onelinecard
tar -cv * | docker exec -i composer tar x -C /home/composer/.composer
rm -fr /tmp/onelinecard

cd "${WORKDIR}"

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
� �Z �=�r��r�=��)'�T��d�fa��^�$ ��(��o-�o�%��C"и����'���@~#���|G~ ���WQ�dJ��f�,�3=�=����TSib+����i�@[�{u�t5�k��8�hT$����~R��#>,p����Gb�G��'�7�k;���#ǒ;�}=ެ�/:ز5��Dk�����h
�7!LX���2Y3��ސ[xs�K3��\��F��-�ul���#C���M˱=�����m�?k����i5i��k��;">s�e�z�ظ�}\�S��5�jiJ@ŝ �|�{�At<
}���?���"�{�"�.����J�;X�T�kdhV�n�˃���������#"�������O~U5#T��c���`Į>E�J?T�"s-|�HH�����J1�~ý�d�3��#jwU�z����-,�Y���)�Ot�t�'�ni�-���u��W,,;� cKR[��k`�I���/�K�\�K���a���e�	�|��6�{�A��k�x����?*
�R�B,�qv�W�N��M"���`�KU��XZ��sv���*�49&"-렝��LJ����NX7�-l8�v�j������-�KPw,�$C��VR/�~� "A]sh9Hr-��4�mo�B��p�A�l���Q9���AR�_RF��4L�Vl�I��'��)ذ)o	���B�󲚸�5-Ն�7�H#��RVuSi*Y3�)����Am"�;J�kd{Xݪ��j@�����6����Q @>j��Q��!� j<��w
���bC��M�I(�)���4$5P?׼,>(���gA��9�~(9�?s�\>C�a�G��=���a�	�;i�q��r�_���D�<Ts�LB�i�jj��dCEn��Y�ahF}x(`3�B�c��>c.��Z}��!��6
|x�h5�X�<X�?l!�E�^��Xi���~��l��a�Qx�B0`C������@夔��̅q��(w�Z�ER�>�۰�Z�D��{IZ13h@s���)��du1����B��`(����x���+w���xD`�@�cRiO�G�́0O�A��2�Vu2F���3֧ʣ ڝA���h�����.LA��!����V���Ʌ�\��Z�Ȯ���4��<��bt,��XǊ��Mi �Z6�%b﫽��N�#���Y��1��m�f�3�'�3�f�n�	��� �w�FX�R�\�IϨ:�@�
Ny�ŋ!����4/���>�?۲¨���K��
S�2��m������hx��/��?_7L��a_���ϋBtR�yn������pƳμM�G3��#֘e�,C��mK�z6�kY� L`��V�Ie�[1�0�l�})Y���~��	��8�W߰+����������ʁs0r3R��M�?LK����ˡ��ۼcH��k��Y�v[�AC�ux��H�/����X���4�"��Vǳ@X�\��T�����l.�_)_/��4��zjc�,�~v�
c����WbZxk�Oo�@����5� ��޼A�So��Z�{�	�-�u����ᶪ�b����*E<)K�dFE't�oVd0�.ِ?���h!vrX 
;>�دh������X&�S�g5�e�	�+�?�e��b���?�US���ӛh�p"Z��6,����e�P�� ����Y4���a��'[�}:���?�s��_,,,�p���<�X���n!̀�u��P��P!���}�u�S��`�����c�}������řk̚���O��hX$��-�����y.����b�	�?�.������o���N�e;[�i����� �jɆj�p����!g]4�|s-�H���֯.]��_o�&
~�>�-5\���Q�W�.�ɱ{��[�����oD.�Q�W�_���+j)�r�w���
��H�9��ME�I����'V��s(8J�Z���)D�&_=�	d�Ъ��ۡ�F��"�T1;V�����3g2x�΀wFW���k3�.R�A3�&�on;��s)d��'����������_ɬ��Y���CD��ͥ2�rVA��y-��ÁH��8Pķ1�6���\P����w�V�ѹK�������P�cEn�����<�Bf�?����'
���������?�I��[���4�xC/��3k�9����ȏFG/Ɇ�H�� ����r�6r"5�����&
d�h��<]~�#�����5���pn�_�> ~$�n�k�dZVoU��Ɂ����&f���FU?q�{���w�8ʦb{��}�O�Hs�>�Z�g�`McD<9���ܬ!w�8!���$����ie�5fD6��>�:��[�V��^>b�@?�������V������J?���;E]��K���a8=���H ��V6C!jQ7L�ٌq�E���OC�I���݀�2"�>�J���U��Ln�uLlm�ҧE��1a�@�A���?��"U�{�5���6(�;�S7���5q�P�K��T�Ջ��\�r�s�oP��KhC���I>F�ngS$!W:��¦�@N��K��a��C��~��>޺�Y���k;&qhjZ=D�hʆv.Ӱ��d3�\�,Dt���J&�*ۤ�!�e���X�Z��F�ۨm�qM�J\l*m�2��EN������1Y�ˢ����L2],/Dj[�DW�C
��`�hP�p���0���K�/TA�H��َ�U�N���D��Q�	��5�!P�h#��z�I����Y��JzC���S#�3!W��2!�֢��J����ӧ?�dڥ�Y)%XV`�Ɔ��,s�O�/����7OP�,�/"N�	B$�������b6�m���t�/���_1��=��KƔ�?�8��q7��もf���N��������x�w��4}r?\1�=pj�H��a>x?�ː��L�	�;���Ҟ2`xm!"�gaɣNn�jȯ�5ܯ=s�n�j׸d���w�nr�(����Xp�X�#�����м�F�:8+���>�% �k����í����<����|��-�?w���$�MOA�l��7<����&��"��2�{!��߷�{��w�~�����?����������_p��)�(�7j
��b\�Uk���Gkո 
1�<�b���,�#�8_�mD��F$���2���$�"���wR����c0DV��"��ʣ�W&i�i9��Z���?2+�l���}��oƉ��7�}3�ò��閎���+���V���?@��o��7G8����O+��o	�8EL�MGp��>�O���d��=�����Z�w�q��?�-����G��`��6<f�����#��r�_\�>;�Qv���
iO��L�<.��2��r�M���B.6 _'�GKƇ3��n^���C3�Y��8=@���Xhj��!$H���yD�'��lR*�i�[#��&�O�III֥n6!ճE)�����=5��c��n�n�~��5O��\p��yz(H�m����\��0w�>���z�H���|������W�|�>˜J/O)�!OKl�5�V�=��ca�l�,��0�rz;�;9O�'����}R��V�l'%�N����^k*fw���se��?�
�r��/g�#�vJӸ~�[��4Q��n�p�:,���W���t9Gj�L�vBƖ�N:J+�>.��r��W�\��Q2n6}�;>��ʯ���t-��(������|��-�\)��팣l��{�|�ZN�@K&rۉއ�RN�K��v2��w$.+%�ݍݳD��n��ʹCs�˿֎w�N#N4�pT,�J�{ͣØ^�Ԏ�]i7#�%M��b'��v7��/ŲvN=(FO�to���=-�{9I�� i�T7�u��w�))G�z��KH���t*I��Mj�f��f.�+e-�Dvc�l"�ְ�{��n�C�����-.���4�UdF����A͠�W�r�J2[H��n!��H����c,n����Q<�0N��R�.G��a��TC�l�ٍ�����jf�t[Ng��x�-�5^�vdN�%�x���+Ei�A�|:������e0��g�=�h>�32�ӵ~���Ș-��|��������o��sެ�/>r��w��G;~�/aA�?��O���y~��������>����\v{�d�5:��uebC
u��v�����k�j�1s�/r%�5�o�zGϤ�r^�-�� �+)IE����|���4�3r2���Pl%u�y�3�a��+#�HFǑ�Ꮀ�Փ�#�b�ny_���H�T����v�n�D�a撏���w�b���?����{��ϋ���"$$d����$f^7���Kb�u��y}$f^���Cb�u��y�#f^����;b�u��i�s�k����>�O���E���"���n�SW}	�>�O���-�����*��lr���4����o�%����KI%U�Ki9ֵҙTE.g^�Ύ�n���z[>h�3�~�$�k���O^���b�a��y��ww��������Z���ﴍz9+����֨7)٧n��|���܊	��[�%z��G�������X<AI�ݳh\|6��_V;�$]GE�f�"��B2OH��A�u`�{�M�;˫i��D���  ����E��[u�E��5��hĬY#Q��kY�%r�\���V�a���)҈<���K���< � ���g9 �2[�fl���Z�~߼	E���
�����iETź٥!�d����F^0�@�PQ�/#�1m�{��?v� ��{�QL"�d�%y��[�t�����;������Wrɂܣp�Qǃ7�`C��ޣ���w�P��!D"��u�3]˧�-ԮE�U�� zSu����A�L��Z��|���=m�(�th���dɖ%�C�r9��m���5`��#�mzoP���`��U_ߞLhBO�����{��T��Z)���lٰ����N��IB���76���)C֟QY��s�ꑻ�4��4�^�R6���%z��eWwֽ���	o��؍�^\�����/o$_^�7��MS%�ڀ?�mG�]� }�.��y@�<$�J�B>�uda�MZ�����v��k�	iZ����XH��·W��\!F�#�؀��\{�*@���L!�������g�q$�jfv��awp�|h���0��ng�3�)���t��t9�w�l��9����L;mK��Bڅ�iAsA�@pCb\a9 �1āB܀3DD~�v�>]�U3�T���*2����"��{2(��K�4='us�%����/@��ܵ_�MB@�A�+A�&��>��3�r�\� �I!<>K%�e�Oc�yu�Uz�p�xr�l�<"��Z3 ��k����\��"I� U��;�k7�E���"�A����fH�3�s]Y�3�)�D*k����X��Cވ�y�N*5�938!��(��TxE04�Z\����g�^$+غ��SM����!�,k�r G@[�C��!<�y�2M��!�im𸸷l���D�p���t��&��jș���_�LJ�hrs�ԶQl�����AkC�l�K����c �%UEvݚ�P��p��M�����Hh�1
bza��	*�o��S$q���V��A<Y�,��?���o�K�/ߝ�u�o�d�����ϧ��������k��	������o�{���r�'�ȫ��r1i�}�J%3IU�p�J��TZ#(<I�e5Id���e��Ҕ�%i�ΨI�})�%�$��&�؃������l��ӟ�i�_��'�p���?~������������z{u���͛�￹�E�߈���!�����c_��ؿߏ}v?�������c�
������\��u�$W�L{�1K٢F�'m��V�OÓj�^�v�����W�X��'��Wy �w���Z���BluI~��.�hy_TV)�t�I�Oz�[zy�0��"�bJ��z�Ř�-�!��74�w'\����F٥<2b�����ȻD����@U&
Y�����wQ�~���+����vW.�g]2��-����I�I�.x��jlX'�T��2á�'�JKv��O�r��{��N���X9����&�mj����Fqo(c�U>_�7�Sw��(H�J_��.���kL��`��za$2t%^�#2�����˹�p�+�vx��b&�N�N�^��c��m^/�?k1����hw`Q�y]8����x�LN�m��@6A�-�'	�}�]��E[d3&��3���tO�P9[U���<�sB��T�tJ�w�m���f>�S���N����z_����w���Rj�3*�3*����_�^n2�
�I�J�x)�49(v�B��ϏZD#˞��T����Fn�<+v�/D�1p!v��b�A��yD3�b�ڢ���z�'�A�=������,�?G�������F!]�%,Y����c�{�V[9Y��`e;Er��*i��Q�1N1��)*ߖ�^�5�l�hJ��ĵ�>]O].~�@�<��I�,���c�.a�6_�����mRŪĜ�\BI�B�M�����T�J`3>�MiĈ�uڭ�l�s��nG�K:�2=�	�Q9��9�R�_��v�]�*5L��������<��PY�`7>�}7�K�^���{��ҽ�
_���_X_��z�����j�/���������M>�j�����{���b���?x+�K��5	�y�r8�X���˱�b/�8�Z�߂�EY����ob�K��O���O}�����~t?�����0�/.ee�`e�������W[����β§G)�����R�y��<�4��#��^q�c�x��$�8v�Y�3�\�u��(��<�Uwy�g]��́�D�p�*d�Q�*J�ŴX]����Ȳ.�ǯ'�Y��+"_L�R�Ti��Դ�I˦jTg~�fGD�:��[�3Fx�g��ɚbO
���Q���wVG�|I7�I��"2.v�b��� �Ĳ�8�	��e�.g8����i1!�.��^7�+��jd�LB7�v���;�K��`��Xr�|�t�;\1؆��+E�cy�`�#m9�d�5h�F��Ҏ���
4��D�ۮ�%D�9��:�'v�(S�����pR�� ���t)�Ë􁇿u)�䠢,��r�[JB{Tg�2�)Wm}6h�����s��m��_�V��+�0P��Qe�G,�*�:�Z|R���	��p�eŴ@���qa�{xrǮK��cH�?a�~�����sV/\M�c�-䪔\���mt�5g�Kf�\#��5����x��*��ްc�����9
ce�鹍Q/K���i]�1㌑;&z&��V*"o��#2��(󞢜�=�����]�b��h!Җ^�Q��/.�ٟ��;����#���p��
%�n���0`Div�ejZ�w����a��N�R3=/al�/�#�'��E���s-*S(��\��4�W�K���1,�N�ru�ʔV�'Ϥ�ե4QiAA�\�2�'�##=�,[VRR<���2w���r�/H�@4����	�G0�0��z���D۱@�4�:,��\�4K�d�}��&{v�l�x�F�����|8�s6�y��t�_��&�d2�f���Y�LTRf�m
Is���,�L�D��@���C����n�4���O�+W҈�=v�zi�(���\(�J�Xlmq�P���l43,�S%�./f�v�^�9:�.j�|�Q&Ik���;L�h'$�m.��LɮȦN}���G��V��t��*gV���)�K�k��ط�� ��~=�ZTu+���x�:ɵ�|�J��+�}_mh�35�[�ؽ���_�~��jc{f��-�z��e�2���C��X�QMc��ވ�z{��ӧ��O���2��^CeZ�����c/c/�k�>a�`�ơd��C��x��7�K�����zQ��XgL��#��c>����E4Nr$�B]qΦh���H������0�:�l[�ct���o��JG�݋|!�r{���.}�t��?hO�,�f���%�x*y��ERw���n��J�w�sB����i��Gq���5�wx��-�rj##Y�k(
����dپu��@Iv|"M��� w����v]�&x�	�}���Gd�c�o؄(���=�Տv��������G�γ��7
l��جG�����'��fݬr���,�KZ[�9C�����щ���". wLM�뵧t������o�#��V��3(�!C�ZKf�w�-=�AhS����j���Z�L����Sћ@��i�����c��q�1�g(���BE�G'����53��X2
v��D��̛/y�< :_[�!�*�0�X�y��(���x'��O�������,jџ��"�m,��I��:2�k�5AF��xnL�1�=��a�;�&p�u�H�*�ň����z�A�BQ�OΘ���5y�?'�3���V��F6p'�ڏo�ұG��l�ʉv(��:�I`T�eh��{]3�֦�X1&��oX �ȋ,��֋�_��������K&�
1��<����+k
�lq�w��6V�[lS��� � ����z@2�l����/��-��}�����mS��4\Zk�[��a*����[���rhH��ـ�Y�Q�g��N͂���'��I>����3�Ke�og�"���(l��S~��c[�YSls����dM5Y�����6��2�P����ώ��ό3� �D� �J��de�P�%��c���!�Cx.���>J��䙝�Mx-�"^��{M	���m���S�����WA+O�t@6�+NaC*�eX������I{:<H�z�ؙZ��e|=]F�4D���#EZ�E�n�fv$-��l�� v�MG`(�~6�{�ܤ�-0Bƣ�12�����Yv�I��*�?ۮK�'���[GY ���ԐL0,u��u��Y��h�o8���l�w5�}��-[ݛ��{��L��)�� ����Dо�"�D�
�&o�F��j����� ���@:ُ��N�!��(�:*����p"��2�#�*���"r
�}7nl9��I���&��c�G�g�,����y�jtт��nAN�1M��P:���<|����8�:�Xs\k:��Ʀ��ܙ��ȱ�RDpގ8��������bG�z����g>�;���6.y�O�����t2��;����ޏ�O��a��Jv�\�x%
�����pdó~g�g؆�;�1�02ғ��(���|��Q��7���� ;:��sQ-xy��Wh|�k=/X���gkG"IU�'�LJ�L���&�I-I�S���h}BM�	I"�$�?K�r_�gSEe4�LI0�-�0(�"���[^�-���rZ� r}�?��r��G/��UG�cA�	�`�峁$����%Y�q*��UI%H�Rp)+IR*Ee�4�Ie��$�0���3��jTZ#������?���o���č?R���s�����t=~�����ؿ�h�%��S{��va1(�k_������P�_�jd[mp|`u����|\���!_~�j�L?���l���|��G�~ni�oSh�|�X垠��K��&�����k*ǔ�fM��D��.+#����O0:W� ��;�c��$����-x����JB7��LF�tv�6�6pP������7�@l�Ϣi0]Ş��.�؁�pζ�=C���$����Ô�QV���"yA��k<��Bt�=Wd�J�ʭKz4��l��Y�P<�+\�*TZOfcc��H$�;��\�&����[=����j�ƏF^xz-P�9�������Us�j��l媕�P8��N�q ��=	��8�hw����$����*����X֋�sP�ق���O�i1,��䬙2�����\�c�1���ꪼOg3�s%��oK(Ga�#�Л�'}ɴ�sH��\$o�<��C$��ĩ�O�W�|�l6��vS��:_�]��d7[A�tU�hc�>^_�<j��(�Q����_�bv���8[+�o��;���e��v�TX)1��Q�1���m?��������g��E�8y��6��\��4���g^�$NB��w��鹯�}��O�)�n�o#})���Y�������H7O��i+�u�Fߥ[H������)���J�2�����?�����m�������W_�4|e�m��������������t���͝����&�gJ_
�����N���t[���f%��kx�3*xE��OҊ�JJ6�!-��3�����I9Me4W5�"%�ؾ)��j�/��?�"��ɻ�_��"��v��g��������kkN������ު�|�x�^N*"(��
EQAQ~��Igz�u&�t��^W)'cZ���k～x���4q�cw����b�vu7��=��,���I�^Nۨ���H��P���uȐ�牋��P�pN��go��W���Z�Vo�:D��a�t�1���i��[i�C���~�����&�������ϳ!u�N�cTq�����8��U�	�O`���
T���0X���� �������?�v�/��ǣf��Mj��|j �����8{��������U�� �D����v���{�g���@���)G�0%Z����������W8��ꄣ:��B#��`��?*A�_�A�_�������O�� �W��?�ր&��4~���C�o%x��7o���s�S���%�9�<��ݐ�VN!���������ڷ�O�Gv?o�!zW���m�y��gQt�Of�����ϗ�Odm83en��Zj��.�f��/�>�).��~��4�̍��Ȼ$K�\hz�d�m�}dY�������)������{}��e����ώ�'{6S�.�+G[�{����b�R��T��?ۮ�ݞ�ǽO�rX����ř�Dz��y.��V�w�C+�QR6�Y�����v�I�Ќw�XN>:[N8�|����ASw�� �B�ƙ��n�A#���kC��ӂ(X � ��ϭ��������H������?�p�w%��'���'�������U��/�#��P�n����l���i��*�(��KP� �P���}xu�߾������>����!4�L�!��o��og?���\�)�w2���?���k�����ؖ2��'�d1�=����mT!<���X��1�����
���jT�R���vߝ0j0���v���dOe=���>t�x��� I�B{.�W�dj*���������Ʒ�O82ե�Q1�-	D#y�>�zk�؆rng˵>c�A��Q�f	�0��$S/<J�☻^1���-�@6�\奋K��Xo����������p�U��o^�<=�P�� ��?��k���|���_	���󅏳������s��}��1���)��� ���dH�a�����&y��B��~4����C�_~f�V�]mu��t��Q�A�4�N��?�6�"OEw�֧���H_��M��[�5Z�|ey�.�h�E�qi�Af˾{XO�C�l��fKJ~v`�(��X���^�t��Ј�:�q;:�޼��oE����Yj���	t}kE��P�ՇF�?��Ԇ������Z��f|B4�����?��;�b5�u�N"6���;Z0g�u��ە��
���R�)}�(c)�1�����;����]"�I:����Q���)���պ$��][�5�L�É��F����P��͸���ք�����;����0��_���`���`�����?��@#����?��W^�ny��5�QyG�𸙲���+�r�����W������%���e�Um-� ���8 ���}x�U��q���J��� �yZ�������SR+�-����a�[mT�z��ooW�%�:R�����6�y�������\��U���o���*r��\󁾛D_^�-����J�3 L�-�x�b��ū�D����E�h��X�}/�C/��gL�5���2]��7Ls��-��w��/5!!����O]1%Uk�v8��(7?��@l�fZW���BV�[$e����e�A_��Uȣ���D2B�oR�KM�>��,8:��ힶ_�^4h��é���W>��x0��\Tq�_��a��4���Gh�_��}���+A%��~�EU�����4K@�_ ���!������a��&T��p����}�8��{s�� �x����C�.$=~;�#	b��!ņ��x!,v~�P�?��}��@�}<~���;���R�9�l�tm�c���,�4�c�d�JM:�2�k�d����ŲJj��[��b�}�;���ݐ�`o��t���l&�1�	����`FǮ�8ߟ$�r��a���6���M���ԃ����������_%��P�������U������0�W��o��!㽉 �����	�������P9�������*����w��
���~�����o�8؎��e���K:e�TY'���wP�2�-����BK�Gf�o�!?2�}ke#�:�]s2ʽ	-<�T�.���w��ig��;�e��b�i<�&+:g�%2�=����'c69���	Zۛ[qL�˺�B��U3}>1.�\:Q��l[���An�\�9��vm����qnqsp�#+�"�F�u�m����70���1ѣ���鱗#AWI5%*�L��h�۳�⼒�'<�ܺ-VV���N�b̟�9��EkL�1z�y�N�����γG�������D��in8#��cٕ�	�����ߚP����ݛ
��?��k�8	��5�Z��A�	����o����J ��0���0������$�����s�&�?���C����#� MA#�������_����_������`��W>���nOZ��<F��=�?	�%h�v_����U�*�<������_?����u�f��p����_;���?@�W��?�C�������~p��T�f�?�CT����{�(���� ����K�p����;��?*B�l����?��k��w����A�k!5�	�����*�?@��?@���A�դ� �F@����_#�����Y��U������*�?@��?@�C���������/�#��P�n����l������J�(�����ф��������?����%�����p�U��o^�<=�P�� ��?��k���|�����$������e���q��sOdx%��{X@RX����>�z�Q���Q���M������	���#u|���OSf/��{�8��@�Vx7o�4#S�~_����� �@c>��$INI[�r��[�	�$��I�L��tg]�=�m�cj#%i�#����9�/t;	ig�%:q$-'['M���	/P�9^�r���M(��T���vw/��7�ah���?�C���<��o�h����������� ���\���ߌO�&�?���g�À��s+�E���vH��/B����Q�����9�;e�}���p�[G+1J��l�pX��89��b�����(<�綺G��Q��N����a?���p@;4,0RS��~�.ڀ��h�����w�+B����Gp���_M������ �_���_����z�Ѐu����e�����x���O��?���KǤ4��֚���ĉ�Y������l����n�N]���;�X"o��#w}���ڒOk~�PVw��#��S�\���X�f�`di'�ӏ&6ʨ��"mŬ���������#fG��h`{F�w���v���;}��{�t�m��t�b�����A���x��	+AG^]��E�h��X�}/�C/�M�rbL�5��Ѳ�e�@�SR���w���//�O�>ss5���ٜ�gwa�|��_����h:'�-��R�G�$o�y�H�]wJ���\���f��~�]����0��������X����#���|��'q�%hB��S�?a��|���)�F��*����?���h�~������@5����	��CU������u�����k��aK�0�|��Ѝ���m�1{�q^�ϗ��u�
_���mY�^�?$��fiZt�7��T/��y�z�x�������b�!_=?�P�/=�"�ֺ�t1z�.G7���\�RK��ƖLl����Ӫ�_]W]��@��ے�34i�ʘ�*Ȑ֒�F�J[�)�;���F�R���%o���>n0���e�LJ�x��\R�+��0xn�rOVޓ���^ڹ���b4Sn?�0|����_���]T��>s92cQY�?��dK4�۲�B|�m3�ЮI�V!q���(�k�2GFW�EE�Ebُ-N�#�G�������Dpma:��C�A���C<�Z����zba�g�����.2��,1WAe*�خLxk '����^��G���A��"T��X��|'=�]p8Ex��p��0����7f�X����L@X��b>���B�����k����g���L��n~T��������l������>3��ŜX�b�e��^��U� �+7���o�G�o��;�?4Ƃ�W���p�����U�
����5U\�W�?�~���W	^��������jΝv�Cqr1v4e������j���h�S
����l�������~ȏx7�y��7�E�����~/��6��$���b���쑑�^K����DxfHMNڜ���`����ۊ7�Ѝ�e����l�)�K	����M���7��~�{}��y��y�RnbQ@�Xp��4n�l�uҽ�F�<k[�r"��u)h�c�O���e=�v|�^:����p�R���Z�D��f�Y;E�h�g��A��2S^��R܆K*	[�i۟�����X�ᢲ�������	��x4�������?�1����������O4�ߧ=��<�����w�Mjjk��O��N�)OZ@.:5{� ���25��D@QO��>ж�N4;��4��_U#����]k��2b_0+4��?C��E��{C��������X�����3���*��d�lH�V=��ء,N�U-����W��!r�#U����%q-؏���{-o}�'~���%����Y��ۻ�8��4H��ג�_X�1��������������\��2CZ����?�U�ϒ��·������i���D-(�`�i��u�To�n޽��������\�?Կ\�Q:q�˺��us~)��} �q�/�ɱ������\m���s�O�EÅX��\a?:tu����\p���k�i��V����^��:'�xZ���I�pok�v�MN䠿k������f��_����3G'iY�0�[7�i�]O��hێ��ܒ#,��i�cz�m���%�L��E������B���y�g��H�p�h}h��Ӧ[��������|[��a�����d�qU����Q�\C�Ռq�m�ӡ�VG��`�j�ݫ_��h�m��z�v���ٕ>U������"��e��({�9�Tq'�B�ޔ�ӯ\��O��G�Z����B���A�U ��o������Б���D�쑉��z�'[���T���0����O���V��c8td�����eA�a�)�?���������?������oP��A�w�o���W�B}���H�������!�O�L�?{U���D:�5�Z�� ���^�o�����T@��I� �s@�A���?I\�����R��C]����#����/�dD��."������?��H�� ������	��������T@�� )=�߷�˄���?����Ȃ�CF:2�_��p���P��?@��� ������P=�߷�˄���?22��P�����?��?������P��?���Q��R����#�������F����
������L��0�0�������%�g`�(���<��7!�G��������E�*���R"�o0$A��^bg�f�)�ef�U&Mʰ��U,ѦɖL ò��o�)/�l���c�V?�_�,�����a�:����]e�E��8���r��E��7d���{��_��ǑX�e<Ғ��N�f���dN�"^я}a��R���W#ٲV!���p��¼�%����k��$yT'�<�緃RP��ڡE�%�̙J����T����ƨӶ%1d���nq�z[��K�uTj�~y�W<�y���N
��Yh���':P���
F}�@���Б���?�@���|��@�W�~ɂ�C������� ��m��Ǳ��売a���i۫IK`w���ٓ�%����ek�l��k��7]|+��ĸ������#�WŒ����f�h�5k0S5^��P^ζu�j3r)�v�.�)� �{-�h���������=��xQ�Bdb��!� �� ����!����L�?���E�i���������ZM;�%/�7Z��Y�{����?i�����!Vx��ʄ�/�/| ?���{����
�76�Q��q�՛��ݼ�ی4}8k��8ϖx�0ʏ�h�߲nͰS~�cK���v׺䶱�f^Q�h�J)��6-�z��68��������R�6n���z��5�>o��1*�i
ф�;�j�W�G/�?'(Ql�|��憨V8�~��{i���O�=��9"Gp�S���.AtdCj�2�ѭ�?7�ue�E�?;LJ�(`�T:� ���؎�k�T�5�tyw`��eȸ֪4����=�K����?������d��������?�j�G�M��a��ۓ	�go����i���?=xY��������������A�� ��'I`�/�����\���?���
����"ਯ�=���\���?`�o*dI��
d�����W�1�
������P��~Ʉ�#n����K��V�D
�����2����22����#2�3���8���7�?NI��������}�8|��"�33˸��������y�����܏$������c�G�a؟��HR?�W�������ۺ��^�7����v�Nثv�!U�#0j��Mi���L��k��h�ָ�O�yg���Nmn0���M#��(<L).(Y��x-���x�0I��~4���������t�vx�`;�����0ϲ�&o��b������G�2Y��v;�s��q��:џ��!���1K-�-A��8�:�z9��ﵡ�Vt*Q��9�Vf~�w�#e�RCi�z������td����?2�������������2��0���,���C�H�L��7��0��
P��A�/���6��`�����"�/�]��}��L�?���#"C�����d"������V�_�$��_�T��M�:���ʥ�ڴ��������>�E�}�h�uwe���K��� `O���P�[��?�Tۭi�VR*�Q`؍�N�^��P�I�\/t��3����M���IН7��y�4�C��D���3e���� `I�����$�?��F\��{T[��e��:���+�b67e�U�ٖd~.����e�#(<��M�7P��I84�ה��(̣�4u���֘�4#}���a��	�G�X���r��ip�W�>�����_��Hܨ�X�O���?U�XC+���h�V.i欈�E�:C�MZ$���&M���eц���Y.��a>o����ɂ��Z������\���NٞC�%�>�z�	���O45b1�����R��dN�r����1܌�Bmo���D?��ީ����j��KZ��]Դ�~?S�S�!�Ӡ���AO�Q�0�Ƣe���6��cX��d������@��'�@�� wN���Б	���?�@��O� �a �Kq�dA�!�C�ό���n5�/$�-�|a�c��F�����Pj��I��#'�l/����v�ߒ��U�Z}�R���ڈƼ����/Y�J��c�=�u�SͰ%��D��^m︎V�5>�	��k�F�5��N�@��� o� FH&�A�2 �� ��������hȂ���"�?D|����g���>7<f���V���Q8���Ք�{������r ��B /s �K;�i+�	������U+
���j���r.��r���S[��bZb�#���~�.��|y`�h�^3�@իDi�on[�j!����6K|�qQ������sUjф�;�*%}���u5�/��[	&!����A�+�d7�jIT�p�[֦c���]��#L=����Ql�~��YN���p�ύ�D�~ڶx����y�y]\j��Z5��l�P>�sw���;���i��M�ح}��Qm���Q�sfO��bmH�s�V�ڝ�`Bu�⤌���w��|�}�f��um�7��b�����SdA���ܜۦ�������O��o�7�Gm+����aN���"|$�c��W{�U����C���������~9��U��	� �a��]ȯ6�2������>oГ�Ga������J�����^��8?�bs��J%w���L6o�7��r���㖇`�}���?�!����'I6����{���q��1�o9�������?s��o��<�qÜ�Z%w�Zsg��a��S1Cӈ7Ƿ��<��&�u��o�ڹ�:�����=˾��¹�3v�o���9~���*J��w���3f��x��߽�7���{�AW��������]���y�,~�;�����,��^?�չV��x߿�{n�>��q����?a7;/�a��h�ŗ������3��9�M?w�sr�&�x#�/s\C�w���W9�E�X����:��[�J�����9A�3s�ko��u��JCl����J�Orwk���3��&��߷^�;�L�������Zz�����|��1�F�3M��6�2�|����q�ŇM�F��_,N�����.��Q�?_�¥���������!�W��I<|v�ߘ��ۢ���赅VSR����� �\�]���y��/?)y��W]�Er��/O���C-                 ����t�� � 