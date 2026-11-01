require_relative '../../../test_helper'

class WtwUk::Internal::TitleSanitizerTest < Minitest::Test
  def test_plain_titles_are_unchanged
    assert_sanitized 'Ghosts: The Possession of Button House', 'Ghosts: The Possession of Button House'
    assert_sanitized "Andrew Lloyd Webber's Starlight Express - Live On Stage",
                     "Andrew Lloyd Webber's Starlight Express - Live On Stage"
    assert_sanitized 'GIANT - The Play', 'GIANT - The Play'
  end

  def test_subtitled_copies
    assert_sanitized 'Wicker', 'Wicker (with subtitles)'
  end

  def test_preview_prefix
    assert_sanitized 'Dune: Part Three', 'See It First - Dune: Part Three'
  end

  def test_film_club_strands
    assert_sanitized 'Apocalypse Now', "Apocalypse Now - Pat's Film Club"
    assert_sanitized "Rosemary's Baby & The Babadook Double Bill",
                     "Rosemary's Baby & The Babadook Double Bill-Pat's Halloween Of Horrors"
  end

  def test_autism_friendly_suffixes
    assert_sanitized 'Forgotten Island', 'Forgotten Island AUTISM FRIENDLY SCREENING'
    assert_sanitized 'Ultimate Thunder', 'Ultimate Thunder - SUBTITLED AND AUTISM FRIENDLY SCREENING'
  end

  def test_q_and_a_suffixes
    assert_sanitized '82: The Ben Nevis Log Challenge (Mandown)', '82: The Ben Nevis Log Challenge (Mandown) inc. Q&A'
    assert_sanitized 'How Deep Is Your Love', 'How Deep Is Your Love plus Director Q&A'
  end

  def test_royal_ballet_and_opera
    assert_sanitized 'Royal Ballet and Opera: Carmen', 'Carmen - Royal Ballet & Opera 26-27 Season'
  end

  def test_exhibition_on_screen
    assert_sanitized 'Exhibition on Screen: Monet', 'Monet - Exhibition On Screen'
  end

  def test_national_theatre_live
    assert_sanitized 'National Theatre Live: Hay Fever', 'NT Live: Hay Fever'
    assert_sanitized 'National Theatre Live: Hay Fever', 'National Theatre Live: Hay Fever'
  end

  def test_film_years
    assert_sanitized 'The Devils', 'The Devils (1971)'
  end

  private

  def assert_sanitized(expected, title)
    assert_equal expected, WtwUk::Internal::TitleSanitizer.new(title).sanitized
  end
end
