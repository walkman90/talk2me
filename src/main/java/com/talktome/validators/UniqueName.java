package com.talktome.validators;

import javax.validation.Constraint;
import javax.validation.Payload;
import java.lang.annotation.*;

/**
 * Created by vokl0313 on 9/26/14.
 */

@Documented
@Constraint(validatedBy = UniqueNameConstraintValidator.class)
@Target( {ElementType.FIELD })
@Retention(RetentionPolicy.RUNTIME)
public @interface UniqueName {

    String message() default "This username already used";

    Class<?>[] groups() default {};

    Class<? extends Payload>[] payload() default {};
}
