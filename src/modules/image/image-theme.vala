public abstract class ImageTheme : Object {
    public abstract void background(Cairo.Context cr);
    public abstract void title_background(Cairo.Context cr);
    public abstract void title_text(Cairo.Context cr);
    public abstract void card_background(Cairo.Context cr);
    public abstract void card_text(Cairo.Context cr);
    public abstract void lesson(Cairo.Context cr);
    public abstract void lesson_replaced(Cairo.Context cr);
    public abstract void lesson_text(Cairo.Context cr);
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
    DARK;
    
    public ImageTheme get_theme() {
        switch (this) {
            case DARK:
                return new DarkTheme();
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
public class DarkTheme : ImageTheme {
    
    public override void background(Cairo.Context cr) {
        cr.set_source_rgb(0, 0.02, 0.04);
    }
    
    public override void title_background(Cairo.Context cr) {
        cr.set_source_rgb(0.05, 0.07, 0.09);
    }
    
    public override void title_text(Cairo.Context cr) {
        cr.set_source_rgb(0.92, 0.94, 0.95);
    }
    
    public override void card_background(Cairo.Context cr) {
        cr.set_source_rgb(0.54, 0.34, 0.9);
    }
    
    public override void card_text(Cairo.Context cr) {
        cr.set_source_rgb(1, 1, 1);
    }
    
    public override void lesson(Cairo.Context cr) {
        cr.set_source_rgb(0.05, 0.07, 0.09);
    }
    
    public override void lesson_replaced(Cairo.Context cr) {
        cr.set_source_rgb(0.10, 0.07, 0.09);
    }
    
    public override void lesson_text(Cairo.Context cr) {
        cr.set_source_rgb(1, 1, 1);
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