public abstract class ImageTheme : Object {
    public abstract void background(Cairo.Context cr);
    public abstract void title_background(Cairo.Context cr);
    public abstract void title_text(Cairo.Context cr);
    public abstract void card_background(Cairo.Context cr);
    public abstract void card_text(Cairo.Context cr);
    public abstract void lesson(Cairo.Context cr);
    public abstract void lesson_replaced(Cairo.Context cr);
    public abstract void lesson_text(Cairo.Context cr);
    public abstract void extra_text(Cairo.Context cr);
    public abstract void credits_text(Cairo.Context cr);
    public abstract void chip_1(Cairo.Context cr, bool is_text = true);
    public abstract void chip_2(Cairo.Context cr, bool is_text = true);
    public abstract void chip_3(Cairo.Context cr, bool is_text = true);
    public abstract void chip_4(Cairo.Context cr, bool is_text = true);
    public abstract void chip_5(Cairo.Context cr, bool is_text = true);
    public abstract void chip_6(Cairo.Context cr, bool is_text = true);
    public abstract void chip_7(Cairo.Context cr, bool is_text = true);
}

public enum SelectedTheme {
    CLASSIC,
    DARK_BLUE;
    
    public static SelectedTheme parse(string theme) {
        switch (theme) {
            case "classic":
                return CLASSIC;
            case "dark_blue":
                return DARK_BLUE;
            default:
                assert_not_reached();
        }
    }
    
    public string to_string() {
        switch (this) {
            case CLASSIC:
                return "classic";
            case DARK_BLUE:
                return "dark_blue";
            default:
                assert_not_reached();
        }
    }
    
    public string to_localized_string() {
        switch (this) {
            case CLASSIC:
                return "Классика";
            case DARK_BLUE:
                return "Темная (Синий)";
            default:
                assert_not_reached();
        }
    }
    
    public ImageTheme get_theme() {
        switch (this) {
            case DARK_BLUE:
                return new DarkBlueTheme();
            case CLASSIC:
            default:
                return new ClassicTheme();
        }
    }
}

[SingleInstance]
public class ClassicTheme : ImageTheme {
    
    public override void background(Cairo.Context cr) {
        cr.set_source_rgb(0.91, 0.91, 0.92);
    }
    
    public override void title_background(Cairo.Context cr) {
        cr.set_source_rgb(0.33, 0.41, 0.47);
    }
    
    public override void title_text(Cairo.Context cr) {
        cr.set_source_rgb(0.92, 0.94, 0.95);
    }
    
    public override void card_background(Cairo.Context cr) {
        cr.set_source_rgb(0.33, 0.50, 0.72);
    }
    
    public override void card_text(Cairo.Context cr) {
        cr.set_source_rgb(1, 1, 1);
    }
    
    public override void lesson(Cairo.Context cr) {
        cr.set_source_rgb(1, 1, 1);
    }
    
    public override void lesson_replaced(Cairo.Context cr) {
        cr.set_source_rgb(0.84, 0.89, 0.95);
    }
    
    public override void lesson_text(Cairo.Context cr) {
        cr.set_source_rgb(0.2, 0.2, 0.2);
    }
    
    public override void extra_text(Cairo.Context cr) {
        cr.set_source_rgb(0.2, 0.2, 0.2);
    }
    
    public override void credits_text(Cairo.Context cr) {
        cr.set_source_rgb(0.6, 0.6, 0.6);
    }
    
    public override void chip_1(Cairo.Context cr, bool is_text = true) {
        cr.set_source_rgba(0.22, 0.56, 0.24, is_text ? 1 : 0.2);
    }
    
    public override void chip_2(Cairo.Context cr, bool is_text = true) {
        cr.set_source_rgba(0.83, 0.18, 0.18, is_text ? 1 : 0.2);
    }
    
    public override void chip_3(Cairo.Context cr, bool is_text = true) {
        cr.set_source_rgba(0.96, 0.49, 0, is_text ? 1 : 0.2);
    }
    
    public override void chip_4(Cairo.Context cr, bool is_text = true) {
        cr.set_source_rgba(0.19, 0.25, 0.62, is_text ? 1 : 0.2);
    }
    
    public override void chip_5(Cairo.Context cr, bool is_text = true) {
        cr.set_source_rgba(0.48, 0.12, 0.64, is_text ? 1 : 0.2);
    }
    
    public override void chip_6(Cairo.Context cr, bool is_text = true) {
        cr.set_source_rgba(0.01, 0.61, 0.90, is_text ? 1 : 0.2);
    }
    
    public override void chip_7(Cairo.Context cr, bool is_text = true) {
        cr.set_source_rgba(1, 0, 0, is_text ? 1 : 0.2);
    }
}

[SingleInstance]
public class DarkBlueTheme : ImageTheme {
    
    public override void background(Cairo.Context cr) {
        cr.set_source_rgb(0.03, 0.08, 0.11);
    }
    
    public override void title_background(Cairo.Context cr) {
        cr.set_source_rgb(0.05, 0.12, 0.16);
    }
    
    public override void title_text(Cairo.Context cr) {
        cr.set_source_rgb(0.84, 0.89, 0.93);
    }
    
    public override void card_background(Cairo.Context cr) {
        cr.set_source_rgb(0.15, 0.29, 0.35);
    }
    
    public override void card_text(Cairo.Context cr) {
        cr.set_source_rgb(0.47, 0.82, 1);
    }
    
    public override void lesson(Cairo.Context cr) {
        cr.set_source_rgb(0.05, 0.12, 0.16);
    }
    
    public override void lesson_replaced(Cairo.Context cr) {
        cr.set_source_rgb(0.09, 0.13, 0.17);
    }
    
    public override void lesson_text(Cairo.Context cr) {
        cr.set_source_rgb(0.84, 0.89, 0.93);
    }
    
    public override void extra_text(Cairo.Context cr) {
        cr.set_source_rgb(0.73, 0.78, 0.82);
    }
    
    public override void credits_text(Cairo.Context cr) {
        cr.set_source_rgb(0.52, 0.57, 0.6);
    }
    
    public override void chip_1(Cairo.Context cr, bool is_text = true) {
        cr.set_source_rgba(0.68, 0.84, 0.51, is_text ? 1 : 0.2);
    }
    
    public override void chip_2(Cairo.Context cr, bool is_text = true) {
        cr.set_source_rgba(0.95, 0.72, 0.71, is_text ? 1 : 0.2);
    }
    
    public override void chip_3(Cairo.Context cr, bool is_text = true) {
        cr.set_source_rgba(1, 0.95, 0.46, is_text ? 1 : 0.2);
    }
    
    public override void chip_4(Cairo.Context cr, bool is_text = true) {
        cr.set_source_rgba(0.19, 0.25, 0.62, is_text ? 1 : 0.2);
    }
    
    public override void chip_5(Cairo.Context cr, bool is_text = true) {
        cr.set_source_rgba(0.7, 0.62, 0.86, is_text ? 1 : 0.2);
    }
    
    public override void chip_6(Cairo.Context cr, bool is_text = true) {
        cr.set_source_rgba(0.3, 0.82, 0.88, is_text ? 1 : 0.2);
    }
    
    public override void chip_7(Cairo.Context cr, bool is_text = true) {
        cr.set_source_rgba(1, 0, 0, is_text ? 1 : 0.2);
    }
}