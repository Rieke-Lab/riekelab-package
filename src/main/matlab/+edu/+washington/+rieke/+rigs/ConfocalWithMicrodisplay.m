classdef ConfocalWithMicrodisplay < edu.washington.rieke.rigs.Confocal
    
    methods
        
        function obj = ConfocalWithMicrodisplay()
            import symphonyui.builtin.devices.*;
            
            ramps = containers.Map();
            ramps('minimum') = linspace(0, 65535, 256);
            ramps('low')     = obj.MICRODISPLAY_LOW_GAMMA_RAMP * 65535;
            ramps('medium')  = obj.MICRODISPLAY_MEDIUM_GAMMA_RAMP * 65535;
            ramps('high')    = obj.MICRODISPLAY_HIGH_GAMMA_RAMP * 65535;
            ramps('maximum') = linspace(0, 65535, 256);
            microdisplay = edu.washington.rieke.devices.MicrodisplayDevice(ramps, 'COM3');
            microdisplay.addConfigurationSetting('micronsPerPixel', 1.2, 'isReadOnly', true);
            obj.addDevice(microdisplay);
            
            frameMonitor = UnitConvertingDevice('Frame Monitor', 'V').bindStream(obj.daqController.getStream('ANALOG_IN.7'));
            obj.addDevice(frameMonitor);
        end
        
    end
    
    properties (Constant)
        % This is a useful command to go from ramp array to this...
        % strjoin(arrayfun(@(x) num2str(x),ramp,'UniformOutput',false),';\n')
        
        MICRODISPLAY_LOW_GAMMA_RAMP = [ ...
            0.18824;
            0.24692;
            0.25563;
            0.26238;
            0.26768;
            0.2723;
            0.27633;
            0.28002;
            0.28373;
            0.28732;
            0.29075;
            0.29386;
            0.29712;
            0.30039;
            0.30362;
            0.30683;
            0.31007;
            0.31305;
            0.31857;
            0.32219;
            0.32509;
            0.32784;
            0.33049;
            0.33305;
            0.33555;
            0.33806;
            0.34059;
            0.34312;
            0.34564;
            0.34808;
            0.35105;
            0.35454;
            0.35798;
            0.36091;
            0.36362;
            0.36631;
            0.36901;
            0.37178;
            0.37461;
            0.37744;
            0.38023;
            0.38315;
            0.38598;
            0.3888;
            0.39182;
            0.39509;
            0.39836;
            0.40157;
            0.40471;
            0.4078;
            0.41081;
            0.41384;
            0.41689;
            0.41993;
            0.42304;
            0.42606;
            0.42912;
            0.43246;
            0.43664;
            0.44097;
            0.44459;
            0.44792;
            0.45103;
            0.45411;
            0.4572;
            0.46029;
            0.4634;
            0.46655;
            0.46958;
            0.47257;
            0.47568;
            0.47929;
            0.48395;
            0.48816;
            0.49161;
            0.49477;
            0.49792;
            0.50037;
            0.50298;
            0.50595;
            0.50909;
            0.51225;
            0.51531;
            0.51825;
            0.52115;
            0.52507;
            0.52942;
            0.53341;
            0.53652;
            0.53948;
            0.54243;
            0.5454;
            0.54828;
            0.55123;
            0.55424;
            0.55724;
            0.56002;
            0.56272;
            0.56556;
            0.56884;
            0.57213;
            0.57515;
            0.57808;
            0.581;
            0.58406;
            0.58688;
            0.58972;
            0.59265;
            0.59576;
            0.59878;
            0.6016;
            0.6044;
            0.60803;
            0.61229;
            0.61596;
            0.61878;
            0.62171;
            0.62464;
            0.62748;
            0.63031;
            0.63316;
            0.636;
            0.63876;
            0.64158;
            0.6444;
            0.64725;
            0.65139;
            0.65568;
            0.65911;
            0.66204;
            0.66493;
            0.66769;
            0.67029;
            0.67301;
            0.67583;
            0.67872;
            0.68143;
            0.68419;
            0.68704;
            0.6901;
            0.69415;
            0.69761;
            0.70066;
            0.70348;
            0.70615;
            0.70875;
            0.71139;
            0.71405;
            0.71674;
            0.71956;
            0.72237;
            0.72504;
            0.72774;
            0.73056;
            0.73355;
            0.73634;
            0.73909;
            0.74178;
            0.7444;
            0.74701;
            0.74952;
            0.75177;
            0.75422;
            0.75689;
            0.75929;
            0.76188;
            0.76481;
            0.76883;
            0.77249;
            0.77542;
            0.77811;
            0.78069;
            0.78337;
            0.78597;
            0.78855;
            0.79125;
            0.79381;
            0.7963;
            0.79887;
            0.80164;
            0.80483;
            0.80877;
            0.81206;
            0.8146;
            0.81715;
            0.81968;
            0.82213;
            0.8246;
            0.82712;
            0.82975;
            0.83238;
            0.83499;
            0.8375;
            0.84025;
            0.84361;
            0.84728;
            0.85022;
            0.85286;
            0.85537;
            0.85777;
            0.86033;
            0.863;
            0.86548;
            0.86795;
            0.87041;
            0.87277;
            0.87512;
            0.87743;
            0.87987;
            0.88239;
            0.88491;
            0.8874;
            0.88988;
            0.89236;
            0.89482;
            0.89722;
            0.89971;
            0.90223;
            0.90465;
            0.90709;
            0.90957;
            0.91279;
            0.91616;
            0.91905;
            0.92155;
            0.92401;
            0.92641;
            0.92873;
            0.93124;
            0.93378;
            0.9361;
            0.93837;
            0.94058;
            0.943;
            0.94566;
            0.9492;
            0.95272;
            0.95528;
            0.95777;
            0.96026;
            0.96264;
            0.96497;
            0.96726;
            0.96958;
            0.97194;
            0.97432;
            0.97672;
            0.97924;
            0.98221;
            0.98542;
            0.98834;
            0.99079;
            0.99319;
            0.9955;
            0.99776;
            1];

        MICRODISPLAY_MEDIUM_GAMMA_RAMP = [ ...
            0.070588;
            0.23989;
            0.24901;
            0.25495;
            0.25965;
            0.26384;
            0.26772;
            0.27123;
            0.27457;
            0.27767;
            0.28094;
            0.28458;
            0.28858;
            0.29175;
            0.29433;
            0.29692;
            0.29932;
            0.30159;
            0.30376;
            0.30592;
            0.30808;
            0.31021;
            0.31219;
            0.31433;
            0.31703;
            0.31936;
            0.32158;
            0.32367;
            0.32576;
            0.32779;
            0.32984;
            0.33202;
            0.33418;
            0.33632;
            0.33866;
            0.34117;
            0.34481;
            0.34791;
            0.35068;
            0.35328;
            0.35588;
            0.35852;
            0.36119;
            0.36389;
            0.36665;
            0.36943;
            0.3722;
            0.37529;
            0.37875;
            0.38216;
            0.38531;
            0.38833;
            0.39142;
            0.39438;
            0.39736;
            0.40043;
            0.40355;
            0.40659;
            0.40968;
            0.41316;
            0.41766;
            0.42189;
            0.42532;
            0.4285;
            0.43164;
            0.43472;
            0.43783;
            0.44092;
            0.44402;
            0.44721;
            0.45041;
            0.45383;
            0.45772;
            0.46152;
            0.46492;
            0.46813;
            0.47128;
            0.47436;
            0.47747;
            0.48058;
            0.48368;
            0.48676;
            0.48988;
            0.49329;
            0.49778;
            0.50129;
            0.50454;
            0.50779;
            0.511;
            0.51409;
            0.51707;
            0.51996;
            0.52294;
            0.52602;
            0.52889;
            0.53202;
            0.53527;
            0.53849;
            0.54162;
            0.54485;
            0.54788;
            0.55091;
            0.55392;
            0.5569;
            0.55993;
            0.56279;
            0.56568;
            0.56885;
            0.57299;
            0.57742;
            0.58088;
            0.58397;
            0.58695;
            0.58992;
            0.59294;
            0.59616;
            0.59918;
            0.60203;
            0.6049;
            0.60797;
            0.61151;
            0.61544;
            0.61858;
            0.62155;
            0.62451;
            0.62757;
            0.63042;
            0.63334;
            0.63629;
            0.63923;
            0.64215;
            0.64528;
            0.64909;
            0.65331;
            0.65676;
            0.65978;
            0.66268;
            0.66575;
            0.66855;
            0.67128;
            0.67416;
            0.67711;
            0.67991;
            0.68263;
            0.686;
            0.68919;
            0.69231;
            0.69527;
            0.69803;
            0.70091;
            0.70371;
            0.70648;
            0.70927;
            0.71204;
            0.71481;
            0.71761;
            0.72134;
            0.72575;
            0.72908;
            0.73201;
            0.73482;
            0.73757;
            0.74033;
            0.74312;
            0.7459;
            0.74861;
            0.75092;
            0.75326;
            0.75641;
            0.75984;
            0.76292;
            0.76578;
            0.76851;
            0.77126;
            0.77404;
            0.77684;
            0.77957;
            0.78231;
            0.78506;
            0.78776;
            0.79122;
            0.79511;
            0.79844;
            0.80134;
            0.80403;
            0.80675;
            0.80937;
            0.81193;
            0.81453;
            0.8171;
            0.81963;
            0.82206;
            0.82459;
            0.82728;
            0.83024;
            0.83299;
            0.8356;
            0.83821;
            0.84079;
            0.84338;
            0.84609;
            0.84882;
            0.85151;
            0.85402;
            0.85704;
            0.86078;
            0.86435;
            0.86727;
            0.86991;
            0.87253;
            0.87513;
            0.87775;
            0.88034;
            0.88293;
            0.88549;
            0.88807;
            0.89079;
            0.89414;
            0.89717;
            0.89988;
            0.90246;
            0.90506;
            0.90764;
            0.91019;
            0.91268;
            0.91519;
            0.91772;
            0.9202;
            0.92317;
            0.92679;
            0.93027;
            0.93321;
            0.93558;
            0.93791;
            0.9402;
            0.94265;
            0.94521;
            0.94763;
            0.95011;
            0.95266;
            0.95531;
            0.95763;
            0.95949;
            0.96174;
            0.96488;
            0.968;
            0.97138;
            0.97495;
            0.97827;
            0.98143;
            0.98468;
            0.98761;
            0.99062;
            0.99401;
            0.99729;
            1];
        
        MICRODISPLAY_HIGH_GAMMA_RAMP = [ ...
            0.066667;
            0.23557;
            0.24514;
            0.25023;
            0.25457;
            0.25833;
            0.26159;
            0.26463;
            0.2675;
            0.27018;
            0.27304;
            0.27648;
            0.27995;
            0.28279;
            0.28507;
            0.28729;
            0.28946;
            0.29151;
            0.29352;
            0.29559;
            0.29768;
            0.30002;
            0.30237;
            0.30456;
            0.30664;
            0.30855;
            0.31042;
            0.3122;
            0.314;
            0.31586;
            0.31773;
            0.31985;
            0.3221;
            0.32495;
            0.32719;
            0.32929;
            0.33132;
            0.33335;
            0.33542;
            0.33749;
            0.33962;
            0.3418;
            0.34409;
            0.34664;
            0.34935;
            0.35185;
            0.35439;
            0.35695;
            0.35943;
            0.36203;
            0.36475;
            0.36735;
            0.37011;
            0.37326;
            0.37746;
            0.38105;
            0.38396;
            0.3869;
            0.38977;
            0.39259;
            0.39551;
            0.39846;
            0.40142;
            0.40449;
            0.40804;
            0.41193;
            0.41511;
            0.41821;
            0.42123;
            0.42421;
            0.42725;
            0.43027;
            0.43329;
            0.43637;
            0.43971;
            0.44407;
            0.44819;
            0.45141;
            0.4545;
            0.45762;
            0.4607;
            0.46377;
            0.46687;
            0.46982;
            0.47271;
            0.47571;
            0.47893;
            0.48219;
            0.48531;
            0.48843;
            0.4915;
            0.49452;
            0.49762;
            0.50016;
            0.50279;
            0.5059;
            0.51053;
            0.5148;
            0.51806;
            0.5209;
            0.52398;
            0.52704;
            0.53009;
            0.53342;
            0.53649;
            0.53951;
            0.5429;
            0.54683;
            0.55049;
            0.55371;
            0.55683;
            0.55974;
            0.56262;
            0.56556;
            0.56872;
            0.57174;
            0.57492;
            0.57886;
            0.58316;
            0.5866;
            0.58974;
            0.59287;
            0.59606;
            0.59913;
            0.60206;
            0.60503;
            0.60815;
            0.61122;
            0.61472;
            0.61805;
            0.6212;
            0.62426;
            0.62728;
            0.6302;
            0.63318;
            0.6362;
            0.63921;
            0.64218;
            0.64587;
            0.65026;
            0.65388;
            0.65701;
            0.66001;
            0.66305;
            0.66604;
            0.669;
            0.67192;
            0.67485;
            0.67797;
            0.68153;
            0.68527;
            0.68838;
            0.69126;
            0.69414;
            0.69693;
            0.69993;
            0.70301;
            0.70596;
            0.70874;
            0.71214;
            0.71631;
            0.72013;
            0.72334;
            0.7263;
            0.72923;
            0.73219;
            0.73508;
            0.73792;
            0.74071;
            0.7434;
            0.74621;
            0.74925;
            0.75182;
            0.7546;
            0.75749;
            0.76025;
            0.76308;
            0.76598;
            0.76894;
            0.7717;
            0.77494;
            0.77911;
            0.78293;
            0.78607;
            0.78898;
            0.79193;
            0.79471;
            0.79753;
            0.80039;
            0.80323;
            0.8061;
            0.80924;
            0.81265;
            0.81572;
            0.81856;
            0.82131;
            0.82405;
            0.8269;
            0.82979;
            0.83263;
            0.83541;
            0.8383;
            0.8421;
            0.84621;
            0.84959;
            0.85254;
            0.85529;
            0.85797;
            0.86081;
            0.86367;
            0.8664;
            0.86915;
            0.87208;
            0.87495;
            0.87693;
            0.87944;
            0.88327;
            0.88639;
            0.8907;
            0.89427;
            0.89826;
            0.90201;
            0.90526;
            0.90896;
            0.9126;
            0.91631;
            0.91956;
            0.92251;
            0.9254;
            0.92821;
            0.93128;
            0.9343;
            0.93691;
            0.93955;
            0.94229;
            0.94516;
            0.94785;
            0.9507;
            0.95364;
            0.95653;
            0.95931;
            0.96213;
            0.965;
            0.9677;
            0.97032;
            0.97291;
            0.97557;
            0.97838;
            0.98131;
            0.98429;
            0.98697;
            0.98951;
            0.99194;
            0.99477;
            0.99746;
            1];
        
    end
    
end

