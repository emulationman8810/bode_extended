function bode_extended(obj, type, mode, rule)
% Based on Gal Barkai script (https://github.com/GalBarkai/asymptotic_bode/releases/tag/V1.2)
% Forked by emulation_man to include real plots, complex poles/zeros 
% and phase plotting rule of 4.81

% BODE_EXTENDED(obj, type, mode, rule)
% type: 'both', 'mag', 'phase'
% mode: 'both', 'asymp', 'real'
% rule: '1dec', '4.81'

if nargin < 2 || isempty(type), type = 'both'; end
if nargin < 3 || isempty(mode), mode = 'both'; end
if nargin < 4 || isempty(rule), rule = '4.81'; end

% --- 1. Analisi Strutturale ---
K_gain = zpk(obj).k;
z_all = zpk(obj).Z{:};
p_all = zpk(obj).P{:};

nz0 = sum(abs(z_all) < 1e-7); 
np0 = sum(abs(p_all) < 1e-7);
g = np0 - nz0; 

z_rem = z_all(abs(z_all) > 1e-7);
p_rem = p_all(abs(p_all) > 1e-7);

Kb = K_gain * prod(-z_rem) / prod(-p_rem);

% --- 2. Tabella Contributi ---
w_t = []; 
w_t = analyze_roots(p_rem, -1, w_t);
w_t = analyze_roots(z_rem,  1, w_t);

% --- 3. Range Frequenze ---
min_w = min([0.01, min(w_t(1,:))/10]);
max_w = max([10000, max(w_t(1,:))*10]);
interval = logspace(log10(min_w), log10(max_w), 5000);

% --- 4. Calcolo Asintotico ---
mag_matrix = zeros(size(w_t,2), length(interval));
phi_matrix = zeros(size(w_t,2), length(interval));

for ii = 1:size(w_t,2)
    wc = w_t(1,ii); contrib = w_t(2,ii); re_sign = w_t(3,ii); zeta = w_t(4,ii);
    mag_matrix(ii,:) = (interval >= wc) .* (20 * contrib * log10(interval/wc));
    
    r = 10; if strcmpi(rule,'4.81'), r = 4.81^zeta; end
    ws = wc/r; we = wc*r;
    
    phi_target = (abs(contrib) * (pi/2)) * sign(contrib) * sign(-re_sign);
    m_phi = phi_target / (2 * log10(r));
    phi_matrix(ii,:) = (interval > ws & interval < we) .* (m_phi * log10(interval/ws)) + ...
                       (interval >= we) .* phi_target;
end

mag_asym = sum(mag_matrix,1) + 20*log10(abs(Kb)) - 20*g*log10(interval);
phi_asym_deg = rad2deg(sum(phi_matrix,1) - g*(pi/2) + (sign(Kb)<0)*pi);

% --- 5. Dati Reali e Allineamento ---
[m_r_raw, p_r_raw, w_r] = bode(obj, interval); % Estratti correttamente m_r, p_r e w_r
m_r = mag2db(squeeze(m_r_raw))'; 
p_r = squeeze(p_r_raw)';
phi_asym_deg = phi_asym_deg + round((p_r(1)-phi_asym_deg(1))/360)*360;

% --- 6. Plotting ---
c_a = [1 0.4 0.4]; c_r = [0.4 1 1];

% Sotto-grafico Modulo
if ismember(type, {'both', 'mag'})
    if strcmpi(type, 'both'), s1 = subplot(2,1,1); else, s1 = gca; end
    hold on;
    if ismember(mode, {'asymp', 'both'})
        p_ma = semilogx(interval, mag_asym, 'Color', c_a, 'LineWidth', 2, 'DisplayName', 'Asintotico');
        % Personalizzazione Cursore
        p_ma.DataTipTemplate.DataTipRows(1).Label = 'Pulsazione [rad/s]';
        p_ma.DataTipTemplate.DataTipRows(2).Label = 'Ampiezza [dB]';
        p_ma.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Frequenza [Hz]', interval/(2*pi));
    end
    if ismember(mode, {'real', 'both'})
        p_mr = semilogx(w_r, m_r, '-', 'Color', c_r, 'LineWidth', 1.5, 'DisplayName', 'Reale');
        % Personalizzazione Cursore
        p_mr.DataTipTemplate.DataTipRows(1).Label = 'Pulsazione [rad/s]';
        p_mr.DataTipTemplate.DataTipRows(2).Label = 'Ampiezza [dB]';
        p_mr.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Frequenza [Hz]', w_r/(2*pi));
    end
    ylabel('Ampiezza [dB]'); xlabel('\omega [rad/s]');
    title('Diagramma Modulo', 'Color', 'w');
    format_plot_local();
end

% Sotto-grafico Fase
if ismember(type, {'both', 'phase'})
    if strcmpi(type, 'both'), s2 = subplot(2,1,2); else, s2 = gca; end
    hold on;
    if ismember(mode, {'asymp', 'both'})
        p_pa = semilogx(interval, phi_asym_deg, 'Color', c_a, 'LineWidth', 2, 'DisplayName', 'Asintotico');
        % Personalizzazione Cursore
        p_pa.DataTipTemplate.DataTipRows(1).Label = 'Pulsazione [rad/s]';
        p_pa.DataTipTemplate.DataTipRows(2).Label = 'Fase [deg]';
        p_pa.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Frequenza [Hz]', interval/(2*pi));
    end
    if ismember(mode, {'real', 'both'})
        p_pr = semilogx(w_r, p_r, '-', 'Color', c_r, 'LineWidth', 1.5, 'DisplayName', 'Reale');
        % Personalizzazione Cursore
        p_pr.DataTipTemplate.DataTipRows(1).Label = 'Pulsazione [rad/s]';
        p_pr.DataTipTemplate.DataTipRows(2).Label = 'Fase [deg]';
        p_pr.DataTipTemplate.DataTipRows(end+1) = dataTipTextRow('Frequenza [Hz]', w_r/(2*pi));
    end
    ylabel('Fase [deg]'); xlabel('\omega [rad/s]'); 
    title(['Fase (Regola: ' rule ')'], 'Color', 'w');
    format_plot_local();
end

    % Funzione interna per formattazione rapida
    function format_plot_local()
        grid on; set(gca, 'XScale', 'log', 'Color', [0.15 0.15 0.15], ...
            'XColor', 'w', 'YColor', 'w', 'GridAlpha', 0.3);
        legend('show', 'TextColor', 'w', 'Location', 'best');
    end
end

% --- Funzioni Helper ---
function w_out = analyze_roots(roots_vec, type_id, w_in)
    w_out = w_in; visited = false(size(roots_vec));
    for i = 1:length(roots_vec)
        if visited(i), continue; end
        wn = abs(roots_vec(i));
        if abs(imag(roots_vec(i))) < 1e-7
            w_out(:,end+1) = [wn; type_id; sign(real(roots_vec(i))); 1];
            visited(i) = true;
        else
            w_out(:,end+1) = [wn; 2*type_id; sign(real(roots_vec(i))); abs(real(roots_vec(i)))/wn];
            conj_idx = find(abs(roots_vec - conj(roots_vec(i))) < 1e-7, 1);
            if ~isempty(conj_idx), visited([i, conj_idx]) = true; else, visited(i) = true; end
        end
    end
end